require_relative "../../../support/utils"
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
      scope "page_prepare_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'preparepage_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Prepare" do

    it "a component can resolve data before rendering in a prepare method" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @hello = "Hello World from Example Page!"
        end

        def response
          div do
            plain @hello
          end
        end

      end

      visit "page_prepare_spec/page_test"

      expect(page).to have_content("Hello World from Example Page!")
    end

  end

end
