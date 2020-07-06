require_relative "../../../../../support/utils"
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
      scope "component_prepare_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Prepare" do

    it "a component can resolve data before rendering in a prepare method" do

      class SomeStaticComponent < Matestack::Ui::StaticComponent

        def prepare
          @some_data = "some data"
        end

        def response
          div id: "my-component" do
            plain @some_data
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

      visit "component_prepare_spec/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"some data")]')

    end

  end

end
