require_relative "../../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do

    class ComponentTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "component_argument_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Argument" do

    it "a component can access a simple argument, if no hash was given" do

      class SomeStaticComponent < Matestack::Ui::Component

        def response
          div id: "my-component" do
            plain @argument
          end
        end

        register_self_as(:some_static_component)
      end

      class ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            some_static_component "foo from page"
          end
        end

      end

      visit "component_argument_spec/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from page")]')

    end

  end

end
