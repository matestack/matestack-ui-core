require_relative "../../../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do
    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::ApplicationHelper
      layout "application"

      def my_action
        render ExamplePage
      end
    end

    Rails.application.routes.append do
      scope "component_static_rendering_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'static_component_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  describe "static components" do

    it "can render static content without any javascript involved if inherit from 'Matestack::Ui::Component'" do
      class SomeStaticComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            plain "static component"
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

      visit "component_static_rendering_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"static component")]')
    end

  end

end
