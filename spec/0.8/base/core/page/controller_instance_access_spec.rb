require_relative "../../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "page_controller_instance_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "can access controller instance variables" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain @bar
        end
      end

    end

    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        @bar = "foo"
        render ExamplePage
      end

    end

    visit "page_controller_instance_spec/page_test"

    expect(page).to have_content("foo")
  end

end
