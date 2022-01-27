require 'rails_core_spec_helper'
include CoreSpecUtils

describe 'Creating custom components', type: :feature, js: true do

  before :all do
    module Components end

    module Pages end

    module Matestack::Ui::Core end

    class ComponentTestController < ActionController::Base
      include Matestack::Ui::Core::Helper
      matestack_layout App

      def my_action
        render(ExamplePage)
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

    class ExamplePage < Matestack::Ui::Page
      def response
        div id: 'div-on-page' do
          crazy_component
        end
      end
    end

    visit '/custom_component_test'
    expect(page).to have_xpath('//div[@id="div-on-page"]/div[@id="my-component-1" and contains(.,"I\'m a static component!")]')
  end

end
