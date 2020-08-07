require_relative "../../../../support/utils"
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
        render Pages::ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "component_dynamic_event_bus_access_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "dynamic components can access the global vuejs event bus" do

    it "and emit events" do
      # the vue.js component 'my-test-component' is defined in `spec/dummy/assets/javascripts/test/components.js`
      class TestComponent < Matestack::Ui::VueJsComponent

        def response
          div id: "my-component" do
            button attributes: {"@click": "emitMessage(\"some_event\", \"hello event bus!\")"} do
              plain "click me!"
            end
          end
        end

        register_self_as(:test_component)
      end


      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            test_component
          end
          async show_on: "some_event" do
            plain "received some_event with: {{event.payload}}"
          end
        end

      end

      visit "component_dynamic_event_bus_access_spec/component_test"

      expect(page).not_to have_content("received some_event with: hello event bus!")

      click_on "click me!"

      expect(page).to have_content("received some_event with: hello event bus!")
    end

    it "and receive events" do
      # the vue.js component 'my-test-component' is defined in `spec/dummy/assets/javascripts/test/components.js`
      class TestComponent < Matestack::Ui::VueJsComponent

        def response
          div id: "my-component" do
            plain "received some_event with: {{received_message}}"
          end
        end

        register_self_as(:test_component)
      end


      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            test_component
          end
          onclick emit: "some_external_event", emit_payload: "hello from outside!" do
            button text: "click me!"
          end
        end

      end

      visit "component_dynamic_event_bus_access_spec/component_test"

      expect(page).not_to have_content("received some_event with: hello from outside!")

      click_on "click me!"

      expect(page).to have_content("received some_event with: hello from outside!")
    end

  end

end
