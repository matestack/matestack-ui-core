require 'rails_core_spec_helper' 
include CoreSpecUtils

describe "Component", type: :feature, js: true do

  before :all do
    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::Helper
      layout "application_core"

      def my_action
        render ExamplePage
      end
    end

    Rails.application.routes.append do
      scope "component_conditional_rendering_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'conditional_component_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  describe "conditional component" do

    it "renders by default if '.render?' method is not overrided" do
      class DefaultRenderingComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            plain "default rendering component"
          end
        end

      register_self_as(:default_rendering_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            default_rendering_component
          end
        end
      end

      visit "component_conditional_rendering_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"default rendering component")]')
    end

    it "renders if '.render?' method is overrided and returns true" do
      class ConditionalRenderingComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            plain "conditional rendering component"
          end
        end

        def render?
          true
        end

      register_self_as(:conditional_rendering_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            conditional_rendering_component
          end
        end
      end

      visit "component_conditional_rendering_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"conditional rendering component")]')
    end

    it "doesn't render if '.render?' method is overrided and returns false" do
      class ConditionalRenderingComponent < Matestack::Ui::Component
        def response
          div id: "my-component" do
            plain "conditional rendering component"
          end
        end

        def render?
          false
        end

      register_self_as(:conditional_rendering_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            conditional_rendering_component
          end
        end
      end

      visit "component_conditional_rendering_spec/component_test"
      expect(page).to_not have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"conditional rendering component")]')
    end

  end

end
