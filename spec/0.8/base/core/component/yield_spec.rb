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
      scope "component_yield_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'yield_component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Yield" do

    it "components can yield a block with access to scope, where block is defined" do
      class SomeStaticComponent < Matestack::Ui::StaticComponent
        def response
          div id: "my-component" do
            yield_components
          end
        end

        register_self_as(:some_static_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def prepare
          @foo = "foo from page"
        end

        def response
          div id: "div-on-page" do
            some_static_component do
              plain @foo
            end
          end
        end
      end

      visit "component_yield_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from page")]')
    end

  end

end
