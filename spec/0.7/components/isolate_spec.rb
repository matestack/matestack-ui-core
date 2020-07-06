require_relative "../../support/utils"
include Utils

describe "Isolate Component", type: :feature, js: true do

  it "behaves like a partial and has access to the page instance vars" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
      end

      def response
        components {
          div id: "page-div" do
            isolate :my_isolated_scope
          end
        }
      end

      def my_isolated_scope
        isolate {
          div id: "isolated-div" do
            plain @foo
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="page-div">
      <div id="isolated-div">
        bar
      </div>
    </div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it "can NOT take any params which are passed in as simple arguments" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
      end

      def response
        components {
          div id: "page-div" do
            isolate :my_isolated_scope, "foo"
          end
        }
      end

      def my_isolated_scope some_param
        isolate {
          div id: "isolated-div" do
            plain @foo
            plain some_param # doesn't work
          end
        }
      end

    end

    visit "/example"

    expect(page).to have_content("isolate > you need to pass params within a hash called 'cached_params'")
  end

  it "can ONLY take params which are passed within a hash called 'cached_params'" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
      end

      def response
        components {
          div id: "page-div" do
            isolate :my_isolated_scope, cached_params: { some_param: "foo" }
          end
        }
      end

      def my_isolated_scope cached_params
        isolate {
          div id: "isolated-div" do
            plain @foo
            plain cached_params[:some_param]
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="page-div">
      <div id="isolated-div">
        bar
        foo
      </div>
    </div>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it "bypasses the main response method of a page if async is used within isolated scope" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
        @test = []
      end

      def response
        components {
          @test.push("response method was here")
          onclick emit: "my_event" do
            button text: "click"
          end
          div id: "page-div" do
            isolate :my_isolated_scope
          end
        }
      end

      def my_isolated_scope
        isolate {
          @test.push("isolted scope method was here")
          async rerender_on: "my_event" do
            div id: "isolated-div" do
              plain @foo
              plain @test
            end
          end
        }
      end

    end

    visit "/example"

    within "#isolated-div" do
      expect(page).to have_content("bar")
      expect(page).to have_content("response method was here")
      expect(page).to have_content("isolted scope method was here")
    end

    click_button "click"

    within "#isolated-div" do
      expect(page).to have_content("bar")
      expect(page).not_to have_content("response method was here")
      expect(page).to have_content("isolted scope method was here")
    end

  end

  it "can access cached_params if bypasses the main response method of a page if async is used within isolated scope" do

    class ExamplePage < Matestack::Ui::Page

      def prepare
        @foo = "bar"
        @test = []
      end

      def response
        components {
          @test.push("response method was here")

          div id: "page-div" do
            [1, 2, 3, 4, 5].each do |id|
              isolate :my_isolated_scope, cached_params: {id: id}
            end
          end
        }
      end

      def my_isolated_scope cached_params
        isolate {
          @test.push("isolted scope method was here")

          async rerender_on: "my_event_#{cached_params[:id]}" do
            div id: "isolated-div-#{cached_params[:id]}" do
              plain @foo
              plain @test
              plain "id: #{cached_params[:id]}"
            end
          end
          onclick emit: "my_event_#{cached_params[:id]}" do
            button text: "rerender only #{cached_params[:id]}"
          end
        }
      end

    end

    visit "/example"

    within "#isolated-div-2" do
      expect(page).to have_content("bar")
      expect(page).to have_content("response method was here")
      expect(page).to have_content("isolted scope method was here")
      expect(page).to have_content("id: 2")
    end

    click_button "rerender only 2"

    within "#isolated-div-2" do
      expect(page).to have_content("bar")
      expect(page).not_to have_content("response method was here")
      expect(page).to have_content("isolted scope method was here")
      expect(page).to have_content("id: 2")
    end

  end

  it "currently only works on page level" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          custom_component
        }
      end

    end

    class Components::Component < Matestack::Ui::StaticComponent

      def response
        components {
          div id: "my-component" do
            isolate :some_isolated_scope
          end
        }
      end

      def some_isolated_scope
        isolate{
          plain "hello!"
        }
      end

    end

    visit "/example"

    expect(page).to have_content("isolate > only works on page level currently. component support is comming soon!")

  end


end
