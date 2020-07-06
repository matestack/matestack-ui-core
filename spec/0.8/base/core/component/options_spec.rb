require_relative "../../../../support/utils"
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
      scope "component_options_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Options" do

    it "components can take an options hash" do

      class SomeStaticComponent < Matestack::Ui::StaticComponent

        def response
          div id: "my-component" do
            plain "got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
          end
        end

        register_self_as(:some_static_component)
      end

      class ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            some_static_component some_option: "hello!", some_other: { option: "world!" }
          end
        end

      end

      visit "component_options_spec/component_test"

      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component" and contains(.,"got some option: hello! and some other option: world!")]')

    end

    it "components can auto validate if options is given and raise error if not" do

      class SpecialComponent < Matestack::Ui::StaticComponent

        REQUIRED_KEYS = [:some_option]

        def response
          div id: "my-component" do
            plain "got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
          end
        end

        register_self_as(:special_component)
      end

      class ExamplePage < Matestack::Ui::Page

        def response
          div id: "div-on-page" do
            special_component some_other: { option: "world!" }
          end
        end

      end

      visit "component_options_spec/component_test"

      expect(page).to have_content("SpecialComponent: required key 'some_option' is missing")
    end

    it "components can manually validate if given options are correct and raise error if not"

  end

end
