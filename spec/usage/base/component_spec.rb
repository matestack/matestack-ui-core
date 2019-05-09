require_relative "../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do
    class ComponentTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

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

    it "custom components defined in the matestack/components folder have to be prefixed with 'custom_' when referenced" do

      module Components end

      module Components::MyComponent end

      module Components::MyComponent::Cell end

      #defined in app/matestack/components/my_component/cell/my_component.rb
      class Components::MyComponent::Cell::MyComponent < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain "I'm a custom static component!"
            end
          }
        end

      end

      #defined in app/matestack/components/my_component/cell/my_second_component.rb
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

      page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')

      expect(page).to have_xpath('//div[@id="div-on-page"]/div/div/div/div[@id="my-component" and contains(.,"I\'m a static component!")]')

      element = page.find("#my-component")
      after_content = element.text

      expect(before_content).not_to eq(after_content)

    end

    it "static component can get options[:dynamic] to turn them into anonymous dynamic components" do

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page", dynamic: true do
              pg id: "my-component", text: 'I am feeling a little dynamic today!'
            end
          }
        end

      end

      visit "/component_test"

      static_output = page.html

      # this is what chrome page source gives me
      expected_static_output = <<~HTML
      <component :component-config='{"id":"div-on-page","dynamic":true,"component_key":"div_1","origin_url":"/component_test"}' :params='{}' inline-template is='anonym-dynamic-component-cell' ref='div-on-page'>
        <div>
          <div v-if=\"asyncTemplate == null\">
            <div id="div-on-page">
              <p id="my-component">I am feeling a little dynamic today!</p>
            </div>
          </div>
          <div v-if="asyncTemplate != null">
            <v-runtime-template :template="asyncTemplate"></v-runtime-template>
          </div>
        </div>
      </component>
      HTML

      # this does not work
      #  expect(stripped(static_output)).to include(stripped(expected_static_output))

      # this does work as expected
      expect(page).to have_xpath('//div[@id="div-on-page"]/p[@id="my-component" and contains(.,"I am feeling a little dynamic today!")]')

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

        MatestackUiCore.Vue.component('dynamic-component-cell', {
          mixins: [MatestackUiCore.componentMixin],
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
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("refresh")')

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
              plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def prepare
          @hello = "hello!"
        end

        def response
          components {
            div id: "div-on-page" do
              static_component some_option: @hello, some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component and got some option: hello! and some other option: world!")]')

    end

    it "components can auto validate if options is given and raise error if not" do

      class Static::Cell::SpecialComponent < Component::Cell::Static

        REQUIRED_KEYS = [:some_option]

        def response
          components {
            div id: "my-component" do
              plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_specialComponent some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_content("div > static_specialComponent > required key 'some_option' is missing")

    end

    it "components can manually validate if given options are correct and raise error if not"

  end

  describe "Slots" do

    it "a page can fill slots of components with access to page instance scope" do

      class Static::Cell::Component < Component::Cell::Static

        def prepare
          @foo = "foo from component"
        end

        def response
          components {
            div id: "my-component" do
              slot @options[:my_first_slot]
              slot @options[:my_second_slot]
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div do
              static_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
            end
          }
        end

        def my_simple_slot
          slot {
            span id: "my_simple_slot" do
              plain "some content"
            end
          }
        end

        def my_second_simple_slot
          slot {
            span id: "my_simple_slot" do
              plain @foo
            end
          }
        end

      end

      visit "/component_test"

      static_output = page.html

      expected_static_output = <<~HTML
      <div>
        <div id="my-component">
          <span id="my_simple_slot">
            some content
          </span>
          <span id="my_simple_slot">
            foo from page
          </span>
        </div>
      </div>
      HTML

      expect(stripped(static_output)).to include(stripped(expected_static_output))

    end

    # todo: Add test to check if placeholder from component works on page if no slot input is defined there

    it "a component can fill slots of components with access to component instance scope" do

      class Static::Cell::Component < Component::Cell::Static

        def prepare
          @foo = "foo from component"
        end

        def response
          components {
            div id: "my-component" do
              static_otherComponent slots: {
                my_slot_from_component: my_slot_from_component,
                my_slot_from_page: @options[:my_slot_from_page]
              }
            end
          }
        end

        def my_slot_from_component
          slot {
            span id: "my-slot-from-component" do
              plain @foo
            end
          }
        end

      end

      class Static::Cell::OtherComponent < Component::Cell::Static

        def prepare
          @foo = "foo from other component"
        end

        def response
          components {
            div id: "my-other-component" do
              slot @options[:slots][:my_slot_from_component]
              slot @options[:slots][:my_slot_from_page]
              plain @foo
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div id: "page-div" do
              static_component my_slot_from_page: my_slot_from_page
            end
          }
        end

        def my_slot_from_page
          slot {
            span id: "my-slot-from-page" do
              plain @foo
            end
          }
        end

      end

      visit "/component_test"

      static_output = page.html

      expected_static_output = <<~HTML
        <div id="page-div">
          <div id="my-component">
            <div id="my-other-component">
              <span id="my-slot-from-component">
                foo from component
              </span>
              <span id="my-slot-from-page">
                foo from page
              </span>
              foo from other component
            </div>
          </div>
        </div>
      HTML

      expect(stripped(static_output)).to include(stripped(expected_static_output))

    end

  end

  describe "Yield" do

    it "components can yield a block with access to scope, where block is defined" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              yield_components
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div id: "div-on-page" do
              static_component do
                plain @foo
              end
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from page")]')

    end

  end

  describe "Partials" do

    it "components can use local partials to structure their response" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              partial :my_partial, "foo from component"
            end
          }
        end

        def my_partial text
          partial {
            plain text
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

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from component")]')

    end

    it "components can use partials from included modules to structure their response" do

      module MySharedPartials

        def my_partial text
          partial {
            plain text
          }
        end

      end

      class Static::Cell::Component < Component::Cell::Static

        include MySharedPartials

        def response
          components {
            div id: "my-component" do
              partial :my_partial, "foo from component"
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

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from component")]')

    end

  end

  describe "Argument" do

    it "a component can access a simple argument, if no hash was given" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain @argument
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component "foo from page"
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from page")]')

    end

  end

  describe "Prepare" do

    it "a component can resolve data before rendering in a prepare method" do

      class Static::Cell::Component < Component::Cell::Static

        def prepare
          @some_data = "some data"
        end

        def response
          components {
            div id: "my-component" do
              plain @some_data
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component "foo from page"
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"some data")]')

    end

  end

  describe "Request Access" do

    it "a component can access request informations" do

      class Static::Cell::Component < Component::Cell::Static

        def response
          components {
            div id: "my-component" do
              plain @url_params[:foo]
            end
          }
        end

      end

      class ExamplePage < Page::Cell::Page

        def response
          components {
            div id: "div-on-page" do
              static_component "foo from page"
            end
          }
        end

      end

      visit "/component_test?foo=bar"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"bar")]')

    end

  end

  describe "Doesn't have Controller Action Scope Access"

  describe "Default Tag Attributes"

  describe "Setup"
end
