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
      scope "page_slots_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end


  it "can fill slots of components with access to page instance scope" do

    class Component < Matestack::Ui::StaticComponent

      def prepare
        @foo = "foo from component"
      end

      def response
        div id: "my-component" do
          slot @options[:my_first_slot]
          slot @options[:my_second_slot]
        end
      end

      register_self_as(:example_component)

    end

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "foo from page"
      end

      def response
        div do
          example_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
        end
      end

      def my_simple_slot
        slot {
          span id: "my_simple_slot" do
            plain "some content"
          end
        }
      end

      def my_second_simple_slot
        slot {
          span id: "my_simple_slot" do
            plain @foo
          end
        }
      end

    end

    visit "page_slots_spec/page_test"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>
      <div id="my-component">
        <span id="my_simple_slot">
          some content
        </span>
        <span id="my_simple_slot">
          foo from page
        </span>
      </div>
    </div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))

  end

end
