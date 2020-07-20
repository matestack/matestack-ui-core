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
      scope "component_custom_namespaces_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'custom_component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  # TODO: their whole naming is also not relevant/true anymore
  describe "CUSTOM component naming and namespaces" do

    it "CUSTOM components are resolved regarding the component registration" do

      #creating the namespace which is represented by "APP_ROOT/app/matestack/components"
      module Components end

      #defined in "APP_ROOT/app/matestack/components/component1.rb
      class Components::Component1 < Matestack::Ui::StaticComponent

        def response
          div id: "my-component-1" do
            plain "my first component"
          end
        end

        register_self_as(:my_first_component)
      end

      #creating the namespace which is represented by "APP_ROOT/app/matestack/components/namespace1"
      module Components::Namespace1 end

      #defined in "APP_ROOT/app/matestack/components/namespace1/component1.rb
      class Components::Namespace1::Component1 < Matestack::Ui::StaticComponent

        def response
          div id: "my-namespaced-component-1" do
            plain "namespaced custom static component"
          end
        end

        register_self_as(:my_namespaced_component)

      end

      #defined in "APP_ROOT/app/matestack/components/component1.rb
      class Components::MyCamelcasedClassNameComponent < Matestack::Ui::StaticComponent

        def response
          div id: "my-camelcased-class-name-component" do
            plain "camelcased class name component"
          end
        end

        register_self_as(:my_camelcased_class_name_component)
      end

      class Pages::ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            my_first_component
            my_namespaced_component
            my_camelcased_class_name_component
          end
          begin
            custom_component1
          rescue
            plain "custom_component1 can not be resolved as there is no more magic class discovery"
          end
          begin
            custom_namespace1_component1
          rescue
            plain "custom_namespace1_component1 can not be resolved as there is no more magic class discovery"
          end
          begin
            custom_myCamelcasedClassNameComponent
          rescue
            plain "custom_myCamelcasedClassNameComponent can not be resolved as there is no more magic class discovery"
          end
        end

      end

      visit "component_custom_namespaces_spec/component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"my first component")]')
      expect(page).to have_content('custom_component1 can not be resolved as there is no more magic class discovery')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-namespaced-component-1" and contains(.,"namespaced custom static component")]')
      expect(page).to have_content('custom_namespace1_component1 can not be resolved as there is no more magic class discovery')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-camelcased-class-name-component" and contains(.,"camelcased class name component")]')
      expect(page).to have_content('custom_myCamelcasedClassNameComponent can not be resolved as there is no more magic class discovery')
    end

  end

end
