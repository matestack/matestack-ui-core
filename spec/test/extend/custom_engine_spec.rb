require_relative "../support/utils"
include Utils

describe "Engine Components", type: :feature, js: true do

  before :all do

    module Components end

    module Pages end

    module Matestack::Ui::Core end

    class EngineComponentTestController < ActionController::Base
      include Matestack::Ui::Core::ApplicationHelper
      layout "application"

      def my_action
        render Pages::ExamplePage
      end
    end

    Rails.application.routes.append do
      get '/engine_component_test', to: 'engine_component_test#my_action', as: 'engine_component_test_action'
    end
    Rails.application.reload_routes!

    module Matestack::Ui::SomeAddon end
  end

  describe "ENGINE component naming and namespaces" do

    it "single ENGINE components are defined in a folder (namespace) called like the component class itself" do

      #creating the namespace which is represented by "ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1"
      module Matestack::Ui::SomeAddon::Component1 end

      #defined in ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1/component1.rb
      module Matestack::Ui::SomeAddon::Component1
        class Component1 < Matestack::Ui::Component
          def response
            div id: "core-component-1" do
              plain "I'm a static addon component!"
            end
          end
          register_self_as(:some_addon_component)
        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            some_addon_component
          end
        end
      end

      visit "/engine_component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1" and contains(.,"I\'m a static addon component!")]')
    end

    it "a ENGINE component may have sub-components structured in subfolders" do
      #creating the namespace which is represented by "ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1"
      module Matestack::Ui::SomeAddon::Component1 end
      #creating the namespace which is represented by "ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1/subcomponent1"
      module Matestack::Ui::SomeAddon::Component1::Subcomponent1 end

      #defined in ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1/component1.rb
      module Matestack::Ui::SomeAddon::Component1
        class Component1 < Matestack::Ui::Component
          def response
            div id: "core-component-1" do
              plain "I'm a static addon component!"
            end
          end

          register_self_as(:some_addon_component)
        end
      end

      #defined in ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/component1/subcomponent1/subcomponent1.rb
      module Matestack::Ui::SomeAddon::Component1::Subcomponent1
        class Subcomponent1 < Matestack::Ui::Component
          def response
            div id: "core-component-1-subcomponent-1" do
              plain "I'm a static addon sub component!"
            end
          end

          register_self_as(:some_addon_sub_component)
        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            some_addon_component
            some_addon_sub_component
          end
        end
      end

      visit "/engine_component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1" and contains(.,"I\'m a static addon component!")]')
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="core-component-1-subcomponent-1" and contains(.,"I\'m a static addon sub component!")]')
    end

    it "camelcased module or class names are referenced with their downcased counterpart" do
      pending "TODO: naming is now rather irrelevant so I think we can get rid off this"

      #creating the namespace which is represented by "ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/some_component"
      module Matestack::Ui::SomeAddon::SomeComponent end

      #defined in ADDON_ENGINE_ROOT/app/concepts/matestack/ui/some_addon/some_component/some_component.rb
      module Matestack::Ui::SomeAddon::SomeComponent
        class SomeComponent < Matestack::Ui::Component
          def response
            div id: "some-core-component" do
              plain "I'm a static component!"
            end
          end
        end
      end

      class Pages::ExamplePage < Matestack::Ui::Page
        def response
          div id: "div-on-page" do
            someAddon_someComponent #not some_component!
          end
        end
      end

      visit "/engine_component_test"
      expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="some-core-component" and contains(.,"I\'m a static component!")]')
    end

  end

end
