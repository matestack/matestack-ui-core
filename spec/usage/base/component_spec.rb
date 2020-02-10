require_relative "../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do

    module Components end

    module Pages end

    module Matestack::Ui::Core end

    class ComponentTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(Pages::ExamplePage)
      end

    end

    Rails.application.routes.append do
      get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
    end
    Rails.application.reload_routes!

  end

  describe "CORE component naming and namespaces" do

    it "single CORE components are defined in a folder (namespace) called like the component class itself" do

      #creating the namespace which is represented by "ENGINE_ROOT/app/concepts/matestack/ui/core/component1"
      module Matestack::Ui::Core::Component1 end

      #defined in ENGINE_ROOT/app/concepts/matestack/ui/core/component1/component1.rb
      class Matestack::Ui::Core::Component1::Component1 < Matestack::Ui::StaticComponent

        def response
          components {
            div id: "core-component-1" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              component1
              #if the last module name and class name are the same
              #the component is referenced by simply lowercased class name ("component1")
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1" and contains(.,"I\'m a static component!")]')

    end

    it "a CORE component may have sub-components structured in subfolders" do

      #creating the namespace which is represented by "ENGINE_ROOT/app/concepts/matestack/ui/core/component1"
      module Matestack::Ui::Core::Component1 end
      #creating the namespace which is represented by "ENGINE_ROOT/app/concepts/matestack/ui/core/component1/subcomponent1"
      module Matestack::Ui::Core::Component1::Subcomponent1 end

      #defined in ENGINE_ROOT/app/concepts/matestack/ui/core/component1/component1.rb
      module Matestack::Ui::Core::Component1
        class Component1 < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "core-component-1" do
                plain "I'm a static component!"
              end
            }
          end

        end
      end

      #defined in ENGINE_ROOT/app/concepts/matestack/ui/core/component1/subcomponent1/subcomponent1.rb
      module Matestack::Ui::Core::Component1::Subcomponent1
        class Subcomponent1 < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "core-component-1-subcomponent-1" do
                plain "I'm a static component!"
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              component1
              component1_subcomponent1
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1" and contains(.,"I\'m a static component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1-subcomponent-1" and contains(.,"I\'m a static component!")]')

      #Note: This approach used for form and form_input for example

    end

    it "camelcased module or class names are referenced with their downcased counterpart" do

      #creating the namespace which is represented by "ENGINE_ROOT/app/concepts/matestack/ui/core/some_component"
      module Matestack::Ui::Core::SomeComponent end

      #defined in ENGINE_ROOT/app/concepts/matestack/ui/core/some_component/some_component.rb
      class Matestack::Ui::Core::SomeComponent::SomeComponent < Matestack::Ui::StaticComponent

        def response
          components {
            div id: "some-core-component" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someComponent #not some_component!
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="some-core-component" and contains(.,"I\'m a static component!")]')

    end

  end

  describe "CUSTOM component naming and namespaces" do

    it "single CUSTOM components are defined in the projects matestack/components folder without any further folder/namespacing required and have to be prefixed with 'custom_' when reference" do

      #creating the namespace which is represented by "PROJECT_ROOT/app/matestack/components"
      module Components end

      #defined in "PROJECT_ROOT/app/matestack/components/component1.rb
      class Components::Component1 < Matestack::Ui::StaticComponent

        def response
          components {
            div id: "my-component-1" do
              plain "I'm a static component!"
            end
          }
        end

      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              custom_component1
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"I\'m a static component!")]')


    end

    it "CUSTOM components can be structured by folders" do

      #creating the namespace which is represented by "PROJECT_ROOT/app/matestack/components"
      module Components end

      #defined in "PROJECT_ROOT/app/matestack/components/component1.rb
      class Components::Component1 < Matestack::Ui::StaticComponent

        def response
          components {
            div id: "my-component-1" do
              plain "I'm a custom static component!"
            end
          }
        end

      end

      #creating the namespace which is represented by "PROJECT_ROOT/app/matestack/components/namespace1"
      module Components::Namespace1 end

      #defined in "PROJECT_ROOT/app/matestack/components/namespace1/component1.rb
      class Components::Namespace1::Component1 < Matestack::Ui::StaticComponent

        def response
          components {
            div id: "my-namespaced-component-1" do
              plain "I'm a namespaced custom static component!"
            end
          }
        end

      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              custom_component1
              custom_namespace1_component1
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"I\'m a custom static component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-namespaced-component-1" and contains(.,"I\'m a namespaced custom static component!")]')

    end

  end

  describe "static vs dynamic components" do

    it "can render static content without any javascript involved if inherit from 'Matestack::Ui::StaticComponent'" do

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                plain "I'm a static component!"
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component!")]')

    end

    it "components can use async component to wrap static components and add basic dynamic behavior" #not working right now

    it "pages can use async component to wrap static components and add basic dynamic behavior" do

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                plain "I'm a static component!"
                plain DateTime.now.strftime('%Q')
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              async rerender_on: "my_event" do
                someStaticComponent
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

    it "components can render dynamic content with vue.js involved if inherit from 'Matestack::Ui::DynamicComponent'" do

      module Matestack::Ui::Core::SomeDynamicComponent
        class SomeDynamicComponent < Matestack::Ui::DynamicComponent

          def response
            components {
              div id: "my-component" do
                plain "I'm a fancy dynamic component!"
                plain "{{dynamic_value}}"
              end
            }
          end

        end
      end

      component_definition = <<~javascript

        MatestackUiCore.Vue.component('matestack-ui-core-somedynamiccomponent', {
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

      class Pages::ExamplePage < Matestack::Ui::Page

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
              someDynamicComponent
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def prepare
          @hello = "hello!"
        end

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent some_option: @hello, some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"I\'m a static component and got some option: hello! and some other option: world!")]')

    end

    it "components can auto validate if options is given and raise error if not" do

      module Matestack::Ui::Core::SpecialComponent
        class SpecialComponent < Matestack::Ui::StaticComponent

          REQUIRED_KEYS = [:some_option]

          def response
            components {
              div id: "my-component" do
                plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              specialComponent some_other: { option: "world!" }
            end
          }
        end

      end

      visit "/component_test"

      expect(page).to have_content("div > specialComponent > required key 'some_option' is missing")

    end

    it "components can manually validate if given options are correct and raise error if not"

  end

  describe "Slots" do

    it "a page can fill slots of components with access to page instance scope" do

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

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
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div do
              someStaticComponent my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def prepare
            @foo = "foo from component"
          end

          def response
            components {
              div id: "my-component" do
                otherComponent slots: {
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
      end

      module Matestack::Ui::Core::OtherComponent
        class OtherComponent < Matestack::Ui::StaticComponent

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
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div id: "page-div" do
              someStaticComponent my_slot_from_page: my_slot_from_page
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                yield_components
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def prepare
          @foo = "foo from page"
        end

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent do
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

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
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          include MySharedPartials

          def response
            components {
              div id: "my-component" do
                partial :my_partial, "foo from component"
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                plain @argument
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent "foo from page"
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

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
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent "foo from page"
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

      module Matestack::Ui::Core::SomeStaticComponent
        class SomeStaticComponent < Matestack::Ui::StaticComponent

          def response
            components {
              div id: "my-component" do
                plain @url_params[:foo]
              end
            }
          end

        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          components {
            div id: "div-on-page" do
              someStaticComponent
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
