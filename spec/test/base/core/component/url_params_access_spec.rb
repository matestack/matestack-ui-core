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
      scope "component_url_params_access_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'url_params_component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Request Access" do

    it "a component can access request informations" do

      class SomeStaticComponent < Matestack::Ui::Component

        def response
            div id: "my-component" do
              # TODO: rather than accessing plain instance variables
              # I'd recommend a method based interface (easier to adjust, test, maintain if state is moved elsewhere etc.)
              plain params[:foo]
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

      visit "component_url_params_access_spec/component_test?foo=bar"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"bar")]')
    end

  end

end
