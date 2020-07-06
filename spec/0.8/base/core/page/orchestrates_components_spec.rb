require_relative "../../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "page_orchestrates_components_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "orchestrates components and can be used as a controller action response" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "Hello World from Example Page!"
        end
      end

    end
    
    visit "page_orchestrates_components_spec/page_test"

    expect(page).to have_content("Hello World from Example Page!")
  end

end
