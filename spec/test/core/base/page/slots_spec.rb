require 'rails_core_spec_helper'
include CoreSpecUtils

describe "Page", type: :feature, js: true do

  before :all do
    class PageTestController < ActionController::Base
      layout "application_core"

      include Matestack::Ui::Core::Helper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "page_slots_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'slots_page_test_action'
      end
    end
    Rails.application.reload_routes!
  end


  it "can fill slots of components with access to page instance scope" do

    class SlotTestComponent < Matestack::Ui::Component

      def prepare
        @foo = "foo from component"
      end

      def response
        div id: "my-component" do
          slot :my_first_slot
          slot :my_second_slot
        end
      end

      register_self_as(:slot_test_component)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        @foo = "foo from page"
        div do
          slot_test_component slots: { my_first_slot: method(:my_simple_slot), my_second_slot: method(:my_second_simple_slot) }
        end
      end

      def my_simple_slot
        span id: "my_simple_slot" do
          plain "some content"
        end
      end

      def my_second_simple_slot
        span id: "my_simple_slot" do
          plain @foo
        end
      end

    end

    visit "page_slots_spec/page_test"

    expect(page).to have_selector("div > div#my-component > span#my_simple_slot", text: "some content")
    expect(page).to have_selector("div > div#my-component > span#my_simple_slot", text: "foo from page")

  end

end
