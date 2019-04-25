require_relative "../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do
    class ComponentTestController < ActionController::Base
      layout "application"

      include Basemate::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    Rails.application.routes.append do
      get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
    end
    Rails.application.reload_routes!

    module Static end

    module Static::Cell end

    module Dynamic end

    module Dynamic::Cell end

  end

  describe "component naming and namespaces" do

    it "components have to be prefixed with two modules, (reflecting two folders on a filesystem); the second has to be 'cell'" do

      module Component1 end

      module Component1::Cell end

      #defined in component1/cell/component1.rb
      class Component1::Cell::Component1 < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              component1
              #if first module name ("Component1") and class name ("Component1") is the same
              #the component is referenced by simply lowercased class name ("component1")
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component!")]')

    end

    it "multiple components may live in one namespace" do

      module Namespace1 end

      module Namespace1::Cell end

      #defined in namespace1/cell/component1.rb
      class Namespace1::Cell::Component1 < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component!"
            end
          }
        end

      end

      #defined in namespace1/cell/component2.rb
      class Namespace1::Cell::Component2 < Component::Cell::Static

        def response
          components {
            div id: "my-component-2" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              namespace1_component1
              namespace1_component2
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-2" and contains(.,"I\'m a static component!")]')

    end

    it "camelcased module or class names are referenced with their downcased counterpart" do

      module MyComponent end

      module MyComponent::Cell end

      #defined in my_component/cell/my_component.rb
      class MyComponent::Cell::MyComponent < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              myComponent #not my_component ! (as this would mean My::Cell::Component)
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component!")]')

    end

    it "custom components defined in the basemate/components folder have to be prefixed with 'custom_' when referenced" do

      module Components end

      module Components::MyComponent end

      module Components::MyComponent::Cell end

      #defined in app/basemate/components/my_component/cell/my_component.rb
      class Components::MyComponent::Cell::MyComponent < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a custom static component!"
            end
          }
        end

      end

      #defined in app/basemate/components/my_component/cell/my_second_component.rb
      class Components::MyComponent::Cell::MySecondComponent < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a second custom static component!"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              custom_myComponent
              custom_myComponent_mySecondComponent
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a custom static component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a second custom static component!")]')

    end

  end

  describe "static vs dynamic components" do

    it "can render static content without any javascript involved if inherit from 'Component::Cell::Static'" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component!"
            end
          }
        end

      end


      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component!")]')

    end

    it "components can use async component to wrap static components and add basic dynamic behaviour" #not working right now

    it "pages can use async component to wrap static components and add basic dynamic behaviour" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component!"
              plain DateTime.now.strftime('%Q')
            end
          }
        end

      end


      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              async rerender_on: "my_event" do
                static_component
              end
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div/div/div/div[@id="my-component" and contains(.,"I\'m a static component!")]')

      element = page.find("#my-component")
      before_content = element.text

      page.execute_script('BasemateUiCore.basemateEventHub.$emit("my_event")')


      expect(page).to have_xpath('//div[@id="div-on-page"]/div/div/div/div[@id="my-component" and contains(.,"I\'m a static component!")]')

      element = page.find("#my-component")
      after_content = element.text

      expect(before_content).not_to eq(after_content)


    end

    it "components can render dynamic content with vue.js involved if inherit from 'Component::Cell::Dynamic'" do

      class Dynamic::Cell::Component < Component::Cell::Dynamic

        def response
          components {
            div id: "my-component" do
              plain "I'm a fancy dynamic component!"
              plain "{{dynamic_value}}"
            end
          }
        end

      end

      component_definition = <<~javascript

        BasemateUiCore.Vue.component('dynamic-component-cell', {
          mixins: [BasemateUiCore.componentMixin],
          data: function data() {
            return {
              dynamic_value: "foo"
            };
          },
          mounted(){
            const self = this
            setTimeout(function () {
              self.dynamic_value = "bar"
            }, 300);
          }
        });

      javascript


      class ExamplePage < Page::Cell::Page

        def response
          components {
            #async rerendering is only needed in this test as we define the
            #vue.js component after initial page load
            async rerender_on: "refresh" do
              partial :relevant_part
            end
          }
        end

        def relevant_part
          partial {
            div id: "div-on-page" do
              dynamic_component
            end
          }
        end

      end

      visit "/component_test"

      page.execute_script(component_definition)

      #async rerendering is only needed in this test as we define the
      #vue.js component after initial page load
      page.execute_script('BasemateUiCore.basemateEventHub.$emit("refresh")')

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a fancy dynamic component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo")]')
      sleep 0.5
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a fancy dynamic component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"bar")]')

    end
  end

  describe "Options" do

    it "components can take a options hash" do
      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component and got some option: #{options[:some_option]} and some other option: #{options[:some_other][:option]}"
            end
          }
        end

      end


      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component some_option: "hello!", some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component and got some option: hello! and some other option: world!")]')
    end

    it "components can validate if options is given and raise error if not" do
      class Static::Cell::Component < Component::Cell::Static

        REQUIRED_KEYS = [:some_option]

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component and got some option: #{options[:some_option]} and some other option: #{options[:some_other][:option]}"
            end
          }
        end

      end


      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_content("div > static_component > required key 'some_option' is missing")

    end

  end

  describe "Slots"

  describe "Yield"

  describe "Partials"

  describe "Prepare"

  describe "Request Access"

  describe "Controller Action Scope Access"

end
