require_relative '../../support/utils'
include Utils

describe 'Creating custom components', type: :feature, js: true do

  before :all do
    module Components end

    module Pages end

    module Matestack::Ui::Core end

    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::ApplicationHelper
      layout 'application'

      def my_action
        render(Pages::ExamplePage)
      end
    end

    Rails.application.routes.append do
      get '/custom_component_test', to: 'component_test#my_action'
    end
    Rails.application.reload_routes!
  end

  it 'by orchestrating existing static core components' do
    module Components end

    class Components::CrazyComponent < Matestack::Ui::Component
      def response
        div id: 'my-component-1' do
          plain "I'm a static component!"
        end
      end

      register_self_as(:crazy_component)
    end

    class Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: 'div-on-page' do
          crazy_component
        end
      end
    end

    visit '/custom_component_test'
    expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"I\'m a static component!")]')
  end

  it 'by orchestrating existing dynamic core components' do
    module Components end

    class Components::OwnDynamic < Matestack::Ui::VueJsComponent
      vue_js_component_name "custom-own-dynamic"

      def response
        div id: 'my-component-1' do
          plain "{{dynamic_value}}"
        end
      end

      register_self_as :own_dynamic
    end

    component_definition = <<~javascript

      MatestackUiCore.Vue.component('custom-own-dynamic', {
        mixins: [MatestackUiCore.componentMixin],
        data: function data() {
          return {
            dynamic_value: "Show on pageview"
          };
        },
        mounted(){
          const self = this
          setTimeout(function () {
            self.dynamic_value = "Show after 300ms"
          }, 300);
        }
      });

    javascript

    class Pages::ExamplePage < Matestack::Ui::Page

      def response
        div id: 'div-on-page' do
          # The async rerender is only used in this test
          # because we add the Vue.js component definition
          # during runtime and therefore need to
          # re-initialize this DOM-part to trigger
          # Vue.js to mount the component properly.
          async rerender_on: "refresh" do
            own_dynamic
          end
        end
      end

    end

    visit '/custom_component_test'
    page.execute_script(component_definition)
    # refresh script only needed in tests, see explanation on page definition above
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("refresh")')
    expect(page).to have_content('Show on pageview')
    sleep 0.5
    expect(page).to have_content('Show after 300ms')
  end

  it 'by extending actionview components - static' do
    module Components end

    class Components::TimeAgo < Matestack::Ui::StaticActionviewComponent
      def prepare
        @from_time = Time.now - 3.days - 14.minutes - 25.seconds
      end

      def response
        div id: 'my-component-1' do
          plain time_ago_in_words(@from_time)
        end
      end

      register_self_as(:time_ago)
    end

    class Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: 'div-on-page' do
          time_ago
        end
      end
    end

    visit '/custom_component_test'
    expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"3 days")]')
  end

  it 'by extending actionview components - dynamic' do
    module Components end

    class Components::TimeClick < Matestack::Ui::DynamicActionviewComponent
      vue_js_component_name "custom-time-click"

      def prepare
        @start_time = Time.now
      end

      def response
          div id: 'my-component-1' do
            plain "{{dynamic_value}} #{distance_of_time_in_words(@start_time, Time.now, include_seconds: true)}"
          end
      end

      register_self_as(:time_click)
    end

    component_definition = <<~javascript

      MatestackUiCore.Vue.component('custom-time-click', {
        mixins: [MatestackUiCore.componentMixin],
        data: function data() {
          return {
            dynamic_value: "Now I show: "
          };
        },
        mounted(){
          const self = this
          setTimeout(function () {
            self.dynamic_value = "Later I show: "
          }, 300);
        }
      });

    javascript

    class Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: 'div-on-page' do
          # The async rerender is only used in this test
          # because we add the Vue.js component definition
          # during runtime and therefore need to
          # re-initialize this DOM-part to trigger
          # Vue.js to mount the component properly.
          async rerender_on: "refresh" do
            time_click
          end
        end
      end
    end

    visit '/custom_component_test'
    page.execute_script(component_definition)
    # refresh script only needed in tests, see explanation on page definition above
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("refresh")')
    expect(page).to have_content('Now I show: less than 5 seconds')
    sleep 0.5
    expect(page).to have_content('Later I show: less than 5 seconds')
  end

end
