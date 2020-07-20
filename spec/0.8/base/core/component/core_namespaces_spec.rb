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
      scope "component_core_namespaces_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'namespace_component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "CORE component naming and namespaces" do

    it "CORE components are resolved regarding the component registration" do

      #creating the namespace which is represented by "CORE_ROOT/app/concepts/matestack/ui/core/component1"
      module Matestack::Ui::Core::Component1 
      end

      #defined in CORE_ROOT/app/concepts/matestack/ui/core/component1/component1.rb
      class Matestack::Ui::Core::Component1::Component1 < Matestack::Ui::StaticComponent
        def response
          div id: "core-component-1" do
            plain "static component 1"
          end
        end

        register_self_as(:some_core_component)
      end

      #defined in CORE_ROOT/app/concepts/matestack/ui/core/component1/component2.rb
      class Matestack::Ui::Core::Component1::Component2 < Matestack::Ui::StaticComponent
        def response
          div id: "core-component-2" do
            plain "static component 2"
          end
        end

        register_self_as(:some_other_core_component)
      end

      #defined in CORE_ROOT/app/concepts/matestack/ui/core/component1/component2.rb
      class Matestack::Ui::Core::Component1::ThirdComponent < Matestack::Ui::StaticComponent
        def response
          div id: "core-component-3" do
            plain "static component 3"
          end
        end

        register_self_as(:third_core_component)
      end

      class Pages::ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            some_core_component
            some_other_core_component
            third_core_component
            begin
              component1
            rescue
              plain "component1 can not be resolved as there is no more magic class discovery"
            end
            begin
              component1_component2
            rescue
              plain "component1_component2 can not be resolved as there is no more magic class discovery"
            end
            begin
              component1_thirdComponent
            rescue
              plain "component1_thirdComponent can not be resolved as there is no more magic class discovery"
            end
          end
        end
      end

      visit "component_core_namespaces_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1" and contains(.,"static component 1")]')
      expect(page).to have_content('component1 can not be resolved as there is no more magic class discovery')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-2" and contains(.,"static component 2")]')
      expect(page).to have_content('component1_component2 can not be resolved as there is no more magic class discovery')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-3" and contains(.,"static component 3")]')
      expect(page).to have_content('component1_thirdComponent can not be resolved as there is no more magic class discovery')
    end

  end

end
