require_relative "../../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do
    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::Helper
      layout "application"

      def my_action
        render ExamplePage
      end
    end

    Rails.application.routes.append do
      scope "component_partials_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'partials_component_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  describe "Partials" do

    it "components can use local partials to structure their response" do
      class SomeStaticComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            my_partial "foo from component"
          end
        end

        def my_partial text
          plain text
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

      visit "component_partials_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from component")]')
    end

    it "components can use partials from included modules to structure their response" do
      module MySharedPartials
        def my_partial text
          plain text
        end
      end

      class SomeStaticComponent < Matestack::Ui::Component
        include MySharedPartials

        def response
          div id: "my-component" do
            my_partial "foo from component"
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

      visit "component_partials_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"foo from component")]')
    end

  end


end
