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
      scope "page_view_context_access_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end


  it "can access ActionView Context" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          if @view_context.view_renderer.instance_of?(ActionView::Renderer)
            plain "has access to ActionView Context"
          end
          plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
          plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
        end
      end

    end

    visit "page_view_context_access_spec/page_test"

    expect(page).to have_content("has access to ActionView Context")
    expect(page).to have_content("Test Link")
    expect(page).to have_content("3 minutes")

  end

  it "can access ActionView Context when async loaded via transition"

end
