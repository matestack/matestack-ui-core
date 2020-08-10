require_relative "../../../support/utils"
include Utils

describe "Isolate Component defer", type: :feature, js: true do

  before :all do
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
      register_self_as(:some_isolated_component_2)

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
    end
  end

  before :each do
    TouchedElementsCounter.instance.reset
  end

  it "is resolved completely independent on the server side if defer true is set" do
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
          some_isolated_component_2 defer: true
        end
      end
    end

    visit "/example"
    # the first request resolves the whole page --> counter + 2
    # the isolated component requests its content right after mount --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 4
    expect(page).to have_css('.some-isolated-component')

    TouchedElementsCounter.instance.reset

    visit "/example?component_class=SomeIsolatedComponent"
    expect(page).to have_css('.some-isolated-component')

    # the above URL is used within the async request of the isolated component in order to get its content
    # only the component itself is resolved on the server side --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 2
  end
  
  it "is deferred by a given time" do
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
          some_isolated_component_2 defer: 2000
        end
      end
    end

    visit "/example"
    # the first request resolves the whole page --> counter + 2
    # the isolated component requests its content right after mount --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 4
    # isolated component should not be rendered directly
    expect(page).not_to have_css('.some-isolated-component', wait: 1)
    # isolated component should be rendered after 2000ms
    expect(page).to have_css('.some-isolated-component', wait: 3)

    TouchedElementsCounter.instance.reset

    visit "/example?component_class=SomeIsolatedComponent"
    expect(page).to have_css('.some-isolated-component')

    # the above URL is used within the async request of the isolated component in order to get its content
    # only the component itself is resolved on the server side --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 2
  end

  it "is deferred by a given time" do
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
    # the isolated component should be rendered with the page --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 4
    expect(page).to have_css('.some-isolated-component')

    TouchedElementsCounter.instance.reset

    visit "/example?component_class=SomeIsolatedComponent"
    expect(page).to have_css('.some-isolated-component')

    # the above URL is used within the async request of the isolated component in order to get its content
    # only the component itself is resolved on the server side --> counter + 2
    expect(TouchedElementsCounter.instance.counter).to eq 2
  end

end
