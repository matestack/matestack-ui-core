require_relative "../../../../../support/utils"
include Utils

describe "App", type: :feature, js: true do

  before :all do

    Rails.application.routes.append do
      scope "app_action_view_context_spec" do
        get 'page1', to: 'example_app_pages#page1', as: 'page1'
        get 'page2', to: 'example_app_pages#page2', as: 'page2'
      end
    end
    Rails.application.reload_routes!

  end

  it "has access to view context" do

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        heading size: 1, text: "My Example App Layout"
        if @view_context.view_renderer.instance_of?(ActionView::Renderer)
          plain "has access to ActionView Context"
        end
        plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
        plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
        main do
          page_content
        end
      end

    end

    module Pages::ExampleApp

    end

    class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

      def response
        div id: "my-div-on-page-1" do
          heading size: 2, text: "This is Page 1"
        end
      end

    end


    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        render Pages::ExampleApp::ExamplePage
      end

    end

    visit "app_action_view_context_spec/page1"

    expect(page).to have_content("has access to ActionView Context")
    expect(page).to have_content("Test Link")
    expect(page).to have_content("3 minutes")

  end

end
