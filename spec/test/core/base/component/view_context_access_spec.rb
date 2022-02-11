require 'rails_core_spec_helper'
include CoreSpecUtils

describe "Component", type: :feature, js: true do

  before :all do

    class SomeLayout < Matestack::Ui::Layout
      def response
        yield
      end
    end

    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::Helper
      matestack_layout SomeLayout

      def my_action
        render ExamplePage
      end
    end

    Rails.application.routes.append do
      scope "component_view_context_access_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'access_component_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  describe "View Context Access" do

    it "a component can access view context scope" do
      class SomeStaticComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            if view_context.view_renderer.instance_of?(ActionView::Renderer)
              plain "has access to ActionView Context"
            end
            plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
            plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
            plain "root_path: #{root_path}" # calling a Path Helper here
          end
        end

        register_self_as(:some_static_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            some_static_component
          end
        end
      end

      visit "component_view_context_access_spec/component_test"
      expect(page).to have_content("has access to ActionView Context")
      expect(page).to have_content("Test Link")
      expect(page).to have_content("3 minutes")
      expect(page).to have_content("root_path: /")
    end

  end

end
