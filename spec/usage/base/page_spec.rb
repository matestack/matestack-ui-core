require_relative "../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
    end
    Rails.application.reload_routes!
  end

  it "orchestrates components and can be used as a controller action response" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          div do
            plain "Hello World from Example Page!"
          end
        }
      end

    end


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    visit "/page_test"

    expect(page).to have_content("Hello World from Example Page!")

  end

  it "can access controller instance variables" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          div do
            plain @bar
          end
        }
      end

    end


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        @bar = "bar"
        responder_for(ExamplePage)
      end

    end

    visit "/page_test"

    expect(page).to have_content("bar")

  end

  it "can resolve data in a prepare method, which runs before rendering"

  it "can use classic ruby within component orchestration"

  it "can provide page instance variables/methods within component orchestration"

  it "can access request informations" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          div do
            plain "Request Params: #{context[:params]}"
          end
        }
      end

    end


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    visit "/page_test/?foo=bar"
    expect(page).to have_content('Request Params: {"foo"=>"bar", "controller"=>"page_test", "action"=>"my_action"}')

  end

  it "wraps a page in a div with page name as id for page specific styling"

  it "can structure the response using local partials" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          div do
            partial :my_simple_partial
            br
            partial :my_partial_with_param, "foo"
            br
            partial :my_partial_with_partial
          end
        }
      end

      def my_simple_partial
        partial {
          span id: "my_simple_partial" do
            plain "some content"
          end
        }
      end

      def my_partial_with_param some_param
        partial {
          span id: "my_partial_with_param" do
            plain "content with param: #{some_param}"
          end
        }
      end

      def my_partial_with_partial
        partial {
          span id: "my_partial_with_partial" do
            partial :my_simple_partial
          end
        }
      end

    end


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    visit "/page_test/?foo=bar"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>

      <span id="my_simple_partial">
        some content
      </span>

      <br/>

      <span id="my_partial_with_param">
        content with param: foo
      </span>

      <br/>

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
        partial {
          span id: "my_partial_with_param" do
            plain "content with param: #{some_param}"
          end
        }
      end

    end

    class ExamplePage < Page::Cell::Page

      include MySharedPartials

      def response
        components {
          div do
            partial :my_simple_partial
            br
            partial :my_partial_with_param, "foo"
            br
            partial :my_partial_with_partial
          end
        }
      end

      def my_simple_partial
        partial {
          span id: "my_simple_partial" do
            plain "some content"
          end
        }
      end

      def my_partial_with_partial
        partial {
          span id: "my_partial_with_partial" do
            partial :my_simple_partial
          end
        }
      end

    end


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    visit "/page_test/?foo=bar"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>

      <span id="my_simple_partial">
        some content
      </span>

      <br/>

      <span id="my_partial_with_param">
        content with param: foo
      </span>

      <br/>

      <span id="my_partial_with_partial">

        <span id="my_simple_partial">
          some content
        </span>

      </span>

    </div>
    HTML


    expect(stripped(static_output)).to include(stripped(expected_static_output))

  end

  it "can fill slots of components with access to page instance scope" do

    module Example
    end

    module Example::Cell
    end

    class Example::Cell::Component < Component::Cell::Static

      def prepare
        @foo = "foo from component"
      end

      def response
        components {
          div id: "my-component" do
            slot options[:my_first_slot]
            br
            slot options[:my_second_slot]
          end
        }
      end


    end

    class ExamplePage < Page::Cell::Page

      def prepare
        @foo = "foo from page"
      end

      def response
        components {
          div do
            example_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
          end
        }
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


    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        responder_for(ExamplePage)
      end

    end

    visit "/page_test/?foo=bar"

    static_output = page.html

    expected_static_output = <<~HTML
    <div>
      <div id="my-component">
        <span id="my_simple_slot">
          some content
        </span>
        <br/>
        <span id="my_simple_slot">
          foo from page
        </span>
      </div>
    </div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))

  end

end
