require 'rails_core_spec_helper' 
include CoreSpecUtils

describe "Page", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "page_controller_instance_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "should not be able to access controller instance variables" do
    class ExamplePage < Matestack::Ui::Page
      optional :bar
      def response
        div do
          plain ctx.bar
        end
        plain @foo
      end
    end

    class PageTestController < ActionController::Base
      include Matestack::Ui::Core::Helper

      def my_action
        @bar = "foo"
        @foo = 'bar'
        render ExamplePage, bar: @bar
      end

    end

    visit "page_controller_instance_spec/page_test"
    expect(page).to have_content("foo")
    expect(page).not_to have_content("bar")
  end

end
