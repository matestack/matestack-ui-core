require_relative "../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::Helper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "page_partials_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'partials_page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "can structure the response using local partials" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
        my_simple_partial
        my_partial_with_param "foo"
        my_partial_with_partial
        end
      end

      def my_simple_partial
        span id: "my_simple_partial" do
          plain "some content"
        end
      end

      def my_partial_with_param some_param
        span id: "my_partial_with_param" do
          plain "content with param: #{some_param}"
        end
      end

      def my_partial_with_partial
        span id: "my_partial_with_partial" do
          my_simple_partial
        end
      end

    end

    visit "page_partials_spec/page_test"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>

      <span id="my_simple_partial">
        some content
      </span>

      <span id="my_partial_with_param">
        content with param: foo
      </span>

      <span id="my_partial_with_partial">

        <span id="my_simple_partial">
          some content
        </span>

      </span>

    </div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it "can structure the response using partials from included modules" do

    module MySharedPartials

      def my_partial_with_param some_param
        span id: "my_partial_with_param" do
          plain "content with param: #{some_param}"
        end
      end

    end

    class ExamplePage < Matestack::Ui::Page

      include MySharedPartials

      def response
        div do
          my_simple_partial
          my_partial_with_param "foo"
          my_partial_with_partial
        end
      end

      def my_simple_partial
        span id: "my_simple_partial" do
          plain "some content"
        end
      end

      def my_partial_with_partial
        span id: "my_partial_with_partial" do
          my_simple_partial
        end
      end

    end

    visit "page_partials_spec/page_test"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>

      <span id="my_simple_partial">
        some content
      </span>

      <span id="my_partial_with_param">
        content with param: foo
      </span>

      <span id="my_partial_with_partial">

        <span id="my_simple_partial">
          some content
        </span>

      </span>

    </div>
    HTML


    expect(stripped(static_output)).to include(stripped(expected_static_output))

  end


end
