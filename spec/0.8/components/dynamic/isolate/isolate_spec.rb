require_relative "../../../../support/utils"
include Utils

describe "Isolate Component", type: :feature, js: true do

  before :each do

    class SomeOtherComponent < Matestack::Ui::StaticComponent

      def response
        div class: "some-other-component" do
          some_isolated_component
        end
      end

      register_self_as(:some_other_component)

    end

    class SomeIsolatedComponent < Matestack::Ui::IsolatedComponent

      def prepare
        @foo_from_component = "foo from isolated component"
      end

      def response
        div class: "some-isolated-component" do
          span id: "text", text: "some isolated compenent"
          span id: "isolated-component-timestamp", text: DateTime.now.to_i
          span id: "foo-from-component", text: @foo_from_component
          span id: "foo-from-url", text: params[:foo_from_url]
          span id: "public-options-id", text: public_options[:id]
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component
        end
      end

    end

  end

  it "is a special type of custom component which can be used on pages and other components" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
      end

      def response
        div id: "page-div" do
          some_isolated_component
          some_other_component
        end
      end

    end

    visit "/example"

    # used on page
    expect(page).to have_xpath('//div[@id="page-div"]/div[@class="matestack-isolated-component-container"]/div[@class="matestack-isolated-component-wrapper"]/div[@class="some-isolated-component"]/span[@id="text" and contains(.,"some isolated compenent")]')

    # used on component
    expect(page).to have_xpath('//div[@id="page-div"]/div[@class="some-other-component"]/div[@class="matestack-isolated-component-container"]/div[@class="matestack-isolated-component-wrapper"]/div[@class="some-isolated-component"]/span[@id="text" and contains(.,"some isolated compenent")]')

  end

  it "is resolved completely independent on the server side" do

    class TouchedElementsCounter
      include Singleton

      attr_reader :counter

      def initialize
        @counter = 0
      end

      def increment
        @counter = @counter + 1
      end

      def reset
        @counter = 0
      end

    end

    class SomeIsolatedComponent < Matestack::Ui::IsolatedComponent

      def prepare
        @counter = TouchedElementsCounter.instance
        @foo = "foo from isolated component"
      end

      def response
        @counter.increment
        div class: "some-isolated-component" do
          @counter.increment
          span id: "text", text: "some isolated compenent"
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component_2)
    end

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @counter = TouchedElementsCounter.instance
        @foo = "bar"
      end

      def response
        @counter.increment
        div id: "page-div" do
          plain "page!"
          @counter.increment
          some_isolated_component_2
        end
      end

    end

    visit "/example"

    # the first request resolves the whole page --> counter + 2
    # the isolated component requests its content right after mount --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 4

    TouchedElementsCounter.instance.reset

    visit "/example?component_class=SomeIsolatedComponent"

    # the above URL is used within the async request of the isolated component in order to get its content
    # only the component itself is resolved on the server side --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 2

  end

  it "needs to be authorized separately" do

    class SomeNonAuthorizedIsolatedComponent < Matestack::Ui::IsolatedComponent

      def response
        span text: "should't work, because authorized? method is not implemented"
      end


      register_self_as(:some_non_authorized_isolated_component)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          plain "page!"
          some_non_authorized_isolated_component
        end
      end

    end

    visit "/example"

    expect(page).to have_content("page!") # rest of the page still works
    expect(page).not_to have_content("should't work, because authorized? method is not implemented")
    expect(page).not_to have_content("please implement the `authorized? method") # async request gets that error, so it's not visible

    visit "/example?component_class=SomeNonAuthorizedIsolatedComponent"

    expect(page).not_to have_content("page!") # page is not requested
    expect(page).not_to have_content("should't work, because authorized? method is not implemented")
    expect(page).to have_content("please implement the `authorized? method")

    class SomeForbiddenIsolatedComponent < Matestack::Ui::IsolatedComponent

      def response
        span text: "should't work, because authorized? method is returning false"
      end

      def authorized?
        false
      end

      register_self_as(:some_forbidden_isolated_component)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          plain "page!"
          some_forbidden_isolated_component
        end
      end

    end

    visit "/example"

    expect(page).to have_content("page!") # rest of the page still works
    expect(page).not_to have_content("should't work, because authorized? method is returning false")
    expect(page).not_to have_content("not authorized") # async request gets that error, so it's not visible

    visit "/example?component_class=SomeForbiddenIsolatedComponent"

    expect(page).not_to have_content("page!") # page is not requested
    expect(page).not_to have_content("should't work, because authorized? method is returning false")
    expect(page).to have_content("not authorized")


    class SomeAuthorizedIsolatedComponent < Matestack::Ui::IsolatedComponent

      def response
        span text: "should work, because authorized? method is returning true"
      end

      def authorized?
        true # could be current_user.admin?
      end

      register_self_as(:some_authorized_isolated_component)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          plain "page!"
          some_authorized_isolated_component
        end
      end

    end

    visit "/example"

    expect(page).to have_content("page!")
    expect(page).to have_content("should work, because authorized? method is returning true")

    visit "/example?component_class=SomeAuthorizedIsolatedComponent"

    expect(page).not_to have_content("page!") # page is not requested
    expect(page).to have_content("should work, because authorized? method is returning true")

  end

  it "its content gets rendered in a async request right after mounted by default" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          span id: "page-timestamp", text: DateTime.now.to_i
          some_isolated_component
        end
      end

    end

    visit "/example"

    # sleep
    page_timestamp = page.find('#page-timestamp').text.to_i
    component_timestamp = page.find('#isolated-component-timestamp').text.to_i

    expect(component_timestamp-page_timestamp).to be < 2

  end

  it "its content gets rendered in a deferred async request after a given time" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          span id: "page-timestamp", text: DateTime.now.to_i
          some_isolated_component defer: 2000
        end
      end

    end

    visit "/example"

    # sleep
    page_timestamp = page.find('#page-timestamp').text.to_i
    component_timestamp = page.find('#isolated-component-timestamp').text.to_i

    expect(component_timestamp-page_timestamp).to be >= 2

  end

  it "has access to url params" do

    visit "/example?foo_from_url=bar"

    foo_from_url = page.find('#foo-from-url').text

    expect(foo_from_url).to eq "bar"

  end

  it "has access to injected (public) options" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component public_options: { id: 3 }
        end
      end

    end

    visit "/example"

    id = page.find('#public-options-id').text.to_i

    expect(id).to eq 3

  end

  it "can not take options like other components, because it's isolated by concept" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component foo: "bar"
        end
      end

    end

    visit "/example"

    expect(page).to have_content("isolated components can only take params in a public_options hash, which will be exposed to the client side in order to perform an async request with these params")

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component foo: "bar", defer: 1000
        end
      end

    end

    visit "/example"

    expect(page).to have_content("isolated components can only take params in a public_options hash, which will be exposed to the client side in order to perform an async request with these params")

  end

  it "can use async components on its response" do

    class SomeIsolatedComponentWithAsync < Matestack::Ui::IsolatedComponent

      def response
        div class: "some-isolated-component-with-async" do
          async rerender_on: "some-event", id: "my-id" do
            span id: "timestamp-in-async", text: DateTime.now.to_i
          end
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component_with_async)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component_with_async
        end
      end

    end

    visit "/example"

    async_timestamp_before = page.find('#timestamp-in-async').text.to_i

    sleep 1

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some-event")')

    expect(page).not_to have_content(async_timestamp_before)

    async_timestamp_after = page.find('#timestamp-in-async').text.to_i #still find a timestamp, otherwise would throw an error

  end

  it "can use other isolated components on its response" do
    class SomeIsolatedComponent1 < Matestack::Ui::IsolatedComponent

      def response
        div class: "some-isolated-component-1" do
          plain "some-isolated-component-1"
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component_1)
    end

    class SomeIsolatedComponent2 < Matestack::Ui::IsolatedComponent

      def response
        div class: "some-isolated-component-2" do
          plain "some-isolated-component-2"
          some_isolated_component_1
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component_2)
    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component_2
        end
      end

    end

    visit "/example"

    within ".some-isolated-component-2" do
      expect(page).to have_content("some-isolated-component-2")
      within ".some-isolated-component-1" do
        expect(page).to have_content("some-isolated-component-1")
      end
    end
  end

  it "has access to rails view context and helpers" do

    class SomeIsolatedComponent < Matestack::Ui::IsolatedComponent

      def response
        div class: "some-isolated-component" do
          if @view_context.view_renderer.instance_of?(ActionView::Renderer)
            plain "has access to ActionView Context"
          end
          plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
          plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component)
    end


    visit "/example"

    expect(page).to have_content("has access to ActionView Context")
    expect(page).to have_content("Test Link")
    expect(page).to have_content("3 minutes")

  end

  it "has 'loading' css class when requesting content" do

    class SomeIsolatedComponent < Matestack::Ui::IsolatedComponent

      def prepare
        sleep 1 # mock hard work
      end

      def response
        div class: "some-isolated-component" do
          plain "result"
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component)
    end


    visit "/example"

    expect(page).to have_css '.loading', visible: :all
    sleep 1
    expect(page).not_to have_css '.loading', visible: :all

  end

  it "has optional 'loading' element when requesting content" do

    class SomeIsolatedComponent < Matestack::Ui::IsolatedComponent

      def prepare
        sleep 1 # mock hard work
      end

      def response
        div class: "some-isolated-component" do
          plain "result"
        end
      end

      def loading_state_element
        div class: "mocked-loading-spinner" do
          plain "loading..."
        end
      end

      def authorized?
        true
      end

      register_self_as(:some_isolated_component)
    end


    visit "/example"

    expect(page).to have_css '.loading-state-element-wrapper.loading', visible: :all
    expect(page).to have_css '.mocked-loading-spinner', visible: :all
    expect(page).to have_content("loading...")
    sleep 1
    expect(page).not_to have_css '.loading-state-element-wrapper.loading', visible: :all
    expect(page).to have_css '.loading-state-element-wrapper', visible: :all
    expect(page).to have_css '.mocked-loading-spinner', visible: :all
    expect(page).to have_content("loading...")
  end

  it "can rerender itself on events" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component rerender_on: "some-event, or-another"
        end
      end

    end

    visit "/example"

    timestamp_before = page.find("#isolated-component-timestamp").text.to_i

    sleep 1

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some-event")')

    expect(page).not_to have_content(timestamp_before)

    timestamp_after = page.find('#isolated-component-timestamp').text.to_i #still find a timestamp, otherwise would throw an error

    sleep 1

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("or-another")')

    expect(page).not_to have_content(timestamp_after)

    timestamp_after_2 = page.find('#isolated-component-timestamp').text.to_i #still find a timestamp, otherwise would throw an error

  end


  it "can rerender itself on events with delay" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component rerender_on: "some-event", rerender_delay: 1500
        end
      end

    end

    visit "/example"

    component_timestamp_before = page.find('#isolated-component-timestamp').text.to_i

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some-event")')

    expect(page).not_to have_content(component_timestamp_before)

    component_timestamp_after = page.find('#isolated-component-timestamp').text.to_i

    expect(component_timestamp_after-component_timestamp_before).to be >= 1

  end

  it "can wait for initial rendering until event" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div id: "page-div" do
          some_isolated_component init_on: "some-event, or-another"
        end
      end

    end

    visit "/example"

    expect(page).not_to have_css '#isolated-component-timestamp', visible: :all

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some-event")')

    expect(page).to have_css '#isolated-component-timestamp', visible: :all

  end

  it "can inherit from a isolate application base class?" do

    class IsolateApplicationBaseComponent < Matestack::Ui::IsolatedComponent

      def authorized?
        true
      end

    end

    class SomeIsolatedChildComponent < IsolateApplicationBaseComponent

      def response
        div class: "some-id" do
          span text: "isolated child component"
          async rerender_on: "some-event", id: "my-id" do
            span id: "timestamp-in-async", text: DateTime.now.to_i
          end
        end
      end

      register_self_as(:some_isolated_component)
    end

    visit "/example"

    async_timestamp_before = page.find('#timestamp-in-async').text.to_i

    sleep 1

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some-event")')

    expect(page).not_to have_content(async_timestamp_before)

    async_timestamp_after = page.find('#timestamp-in-async').text.to_i #still find a timestamp, otherwise would throw an error

  end


  it "can be used on rails legacy views?"


end
