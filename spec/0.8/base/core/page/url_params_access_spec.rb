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
      scope "page_url_params_access_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "can access url params" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "Request Params: #{@url_params}"
        end
      end

    end

    visit "page_url_params_access_spec/page_test/?foo=bar"

    expect(page).to have_content('Request Params: {"foo"=>"bar"}')

  end

end
