require_relative '../../support/utils'
include Utils

describe 'Creating custom components', type: :feature, js: true do

  before :all do

    module Components end

    module Pages end

    module Matestack::Ui::Core end

    class ComponentTestController < ActionController::Base
      layout 'application'

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(Pages::ExamplePage)
      end

    end

    Rails.application.routes.append do
      get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
    end
    Rails.application.reload_routes!

  end

  it 'by orchestrating existing core components' do

    module Components end

    class Components::CrazyComponent < Matestack::Ui::StaticComponent

      def response
        components {
          div id: 'my-component-1' do
            plain "I'm a static component!"
          end
        }
      end

    end

    class Pages::ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: 'div-on-page' do
            custom_crazyComponent
          end
        }
      end

    end

    visit '/component_test'

    expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"I\'m a static component!")]')

  end

  it 'by extending actionview components - static' do

    module Components end

    class Components::TimeAgo < Matestack::Ui::StaticActionviewComponent
    # class Components::TimeAgo < Matestack::Ui::Core::Actionview::Static # without alias

      def prepare
        @from_time = Time.now - 3.days - 14.minutes - 25.seconds
      end

      def response
        components {
          div id: 'my-component-1' do
            plain time_ago_in_words(@from_time)
          end
        }
      end

    end

    class Pages::ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: 'div-on-page' do
            custom_timeAgo
          end
        }
      end

    end

    visit '/component_test'

    expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"3 days")]')

  end

  it 'by extending actionview components - dynamic' do

    module Components end

    class Components::TimeClick < Matestack::Ui::DynamicActionviewComponent
      # class Components::TimeClick < Matestack::Ui::Core::Actionview::Dynamic # without alias

      def prepare
        @start_time = Time.now
      end

      def response
        components {
          div id: 'my-component-1' do
            plain "{{dynamic_value}} #{distance_of_time_in_words(@start_time, Time.now, include_seconds: true)}"
          end
        }
      end

    end

    component_definition = <<~javascript

      MatestackUiCore.Vue.component('custom-timeclick', {
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
        components {
          div id: 'div-on-page' do
            async rerender_on: "refresh" do
              custom_timeClick
            end
          end
        }
      end

    end

    visit '/component_test'

    page.execute_script(component_definition)
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("refresh")')

    expect(page).to have_content('Now I show: less than 5 seconds')
    sleep 0.5
    expect(page).to have_content('Later I show: less than 5 seconds')
  end

end
