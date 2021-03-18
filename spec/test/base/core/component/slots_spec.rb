require_relative "../../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do

    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::Helper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "component_slots_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'slots_component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Slots" do

    it "a page can fill slots of components with access to page instance scope" do

      class SomeStaticComponent < Matestack::Ui::Component
        
        def response
          @foo = "foo from component"
          div id: "my-component" do
            slot :my_first_slot
            slot :my_second_slot
          end
        end

        register_self_as(:some_static_component)
      end

      class ExamplePage < Matestack::Ui::Page
        
        def response
          @foo = "foo from page"
          div do
            some_static_component slots: { my_first_slot: method(:my_simple_slot), my_second_slot: method(:my_second_simple_slot) }
          end
        end

        def my_simple_slot
          span id: "my_simple_slot" do
            plain "some content"
          end
        end

        def my_second_simple_slot
          span id: "my_simple_slot" do
            plain @foo
          end
        end

      end

      visit "component_slots_spec/component_test"

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

      class SomeStaticComponent < Matestack::Ui::Component
        
        def response
          @foo = "foo from component"
          div id: "my-component" do
            other_component slots: {
              my_slot_from_component: method(:my_slot_from_component),
              my_slot_from_page: slots[:my_slot_from_page]
            }
          end
        end

        def my_slot_from_component
          span id: "my-slot-from-component" do
            plain @foo
          end
        end

        register_self_as(:some_static_component)
      end

      class OtherComponent < Matestack::Ui::Component
        
        def response
          @foo = "foo from other component"
          div id: "my-other-component" do
            slot :my_slot_from_component
            slot :my_slot_from_page
            plain @foo
          end
        end

        register_self_as(:other_component)
      end

      class ExamplePage < Matestack::Ui::Page
        
        def response
          @foo = "foo from page"
          div id: "page-div" do
            some_static_component slots: { my_slot_from_page: method(:my_slot_from_page) }
          end
        end

        def my_slot_from_page
          span id: "my-slot-from-page" do
            plain @foo
          end
        end

      end

      visit "component_slots_spec/component_test"

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


end
