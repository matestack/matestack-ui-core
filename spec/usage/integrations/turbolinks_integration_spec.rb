describe "Turbolinks integration", type: :feature, js: true do
  before(:all) do
    FileUtils.cp('spec/usage/application_with_turbolinks.js', 'spec/dummy/app/assets/javascripts/application.js')
  end

  before do
    Rails.application.routes.draw do
      get '/turbolinks', to: 'turbolinks#my_action', as: 'turbolinks_test_action'
    end

    class TurbolinksController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
      end
    end

    module Pages::Turbolinks
    end

    class Pages::Turbolinks::MyAction < Matestack::Ui::Page
      def response
        components {
          plain "Hello from matestack with turbolinks"
        }
      end
    end
  end

  after do
    FileUtils.cp('spec/usage/application.js', 'spec/dummy/app/assets/javascripts/application.js')
    Rails.application.reload_routes!
  end

  specify "Matestack can be used with turbolinks" do
    visit "/turbolinks"

    expect(page).to have_text "Hello from matestack without turbolinks"
  end
end
