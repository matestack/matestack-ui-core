require_relative "../../../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it "rerender on event(s) on page-level" do
    class ExamplePage < Matestack::Ui::Page
      def response
        async rerender_on: "my_event" do
          div id: "my-div" do
            plain "1: #{DateTime.now.strftime('%Q')}"
          end
        end
        some_partial
      end

      def some_partial
        async rerender_on: "multi_event_1, multi_event_2" do
          div id: "my-second-div" do
            plain "2: #{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_content(before_content)
    element = page.find("#my-second-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_1")')
    expect(page).not_to have_content(before_content)
    element = page.find("#my-second-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_2")')
    expect(page).not_to have_content(before_content)
  end

  it "rerender on event behind yield_components" do
    class ExamplePage < Matestack::Ui::Page
      def response
        div do
          some_component do
            async rerender_on: "my_event" do
              div id: "yielded-async-1" do
                plain "yielded timestamp 1: #{DateTime.now.strftime('%Q')}"
              end
            end
          end
        end
      end
    end

    class SomeComponent < Matestack::Ui::StaticComponent
      def response
        div id: "yielded-content-1" do
          yield_components
        end
        other_component do
          async rerender_on: "my_other_event" do
            div id: "nested-yielded-async-2" do
              plain "yielded timestamp 2: #{DateTime.now.strftime('%Q')}"
            end
          end
        end
      end

      register_self_as(:some_component)
    end

    class OtherComponent < Matestack::Ui::StaticComponent
      def response
        div id: "nested-yielded-content-2" do
          yield_components
        end
      end

      register_self_as(:other_component)
    end


    visit "/example"
    content_before = page.find("#yielded-async-1").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_content(content_before)
    within "#yielded-content-1" do
      expect(page).to have_content("yielded timestamp 1: ")
    end
    content_before = page.find("#nested-yielded-async-2").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_other_event")')
    expect(page).not_to have_content(content_before)
    within "#nested-yielded-content-2" do
      expect(page).to have_content("yielded timestamp 2: ")
    end
  end

  it "rerender on event on (nested) component-level" do
    class ExamplePage < Matestack::Ui::Page
      def response
        div do
          some_component
        end
      end
    end

    class SomeComponent < Matestack::Ui::StaticComponent
      def response
        div id: "static-content-on-component" do
          plain "Component 1.1: #{DateTime.now.strftime('%Q')}"
        end
        async rerender_on: "my_event" do
          div id: "dynamic-content-on-component" do
            plain "Component 1.2: #{DateTime.now.strftime('%Q')}"
          end
        end
        some_partial
      end

      def some_partial
        async rerender_on: "my_other_event, some_other_event" do
          div id: "other-dynamic-content-on-component" do
            plain "Component 1.3: #{DateTime.now.strftime('%Q')}"
          end
          other_component
        end
      end

      register_self_as(:some_component)
    end

    class OtherComponent < Matestack::Ui::StaticComponent
      def response
        div id: "static-content-on-other-component" do
          plain "Component 2.1: #{DateTime.now.strftime('%Q')}"
        end
        async rerender_on: "my_event, some_other_event" do
          div id: "dynamic-content-on-other-component" do
            plain "Component 2.2: #{DateTime.now.strftime('%Q')}"
          end
        end
        async rerender_on: "my_other_event" do
          div id: "other-dynamic-content-on-other-component" do
            plain "Component 2.3: #{DateTime.now.strftime('%Q')}"
          end
        end
      end

      register_self_as(:other_component)
    end

    visit "/example"
    static_content_before = page.find("#static-content-on-component").text
    dynamic_content_before = page.find("#dynamic-content-on-component").text
    other_dynamic_content_before = page.find("#other-dynamic-content-on-component").text
    static_content_before_on_other_component = page.find("#static-content-on-other-component").text
    dynamic_content_before_on_other_component = page.find("#dynamic-content-on-other-component").text
    other_dynamic_content_before_on_other_component = page.find("#other-dynamic-content-on-other-component").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_content(static_content_before)
    expect(page).not_to have_content(dynamic_content_before)
    expect(page).to have_content(other_dynamic_content_before)
    expect(page).to have_content(static_content_before_on_other_component)
    expect(page).not_to have_content(dynamic_content_before_on_other_component)
    expect(page).to have_content(other_dynamic_content_before_on_other_component)
    static_content_before = page.find("#static-content-on-component").text
    dynamic_content_before = page.find("#dynamic-content-on-component").text
    other_dynamic_content_before = page.find("#other-dynamic-content-on-component").text
    static_content_before_on_other_component = page.find("#static-content-on-other-component").text
    dynamic_content_before_on_other_component = page.find("#dynamic-content-on-other-component").text
    other_dynamic_content_before_on_other_component = page.find("#other-dynamic-content-on-other-component").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some_other_event")')
    expect(page).to have_content(static_content_before)
    expect(page).to have_content(dynamic_content_before)
    expect(page).not_to have_content(other_dynamic_content_before)
    expect(page).not_to have_content(static_content_before_on_other_component)
    expect(page).not_to have_content(dynamic_content_before_on_other_component)
    expect(page).not_to have_content(other_dynamic_content_before_on_other_component)
  end

  it "rerender on event on page-level if wrapped in app" do
    module Example
    end

    class Example::App < Matestack::Ui::App
      def response
        heading size: 1, text: "My Example App Layout"
        main do
          page_content
        end
      end
    end

    module Example::Pages 
    end

    class Example::Pages::ExamplePage < Matestack::Ui::Page
      def response
        async rerender_on: "my_event" do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    class AsyncInAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def example
        render Example::Pages::ExamplePage, matestack_app: Example::App
      end
    end

    Rails.application.routes.append do
      scope "async_rerender_spec" do
        get 'async_specs/in_app/example', to: 'async_in_app_pages#example', as: 'asyn_in_app_example'
      end
    end
    Rails.application.reload_routes!

    visit "async_rerender_spec/async_specs/in_app/example"
    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    element = page.find("#my-div")
    after_content = element.text
    expect(before_content).not_to eq(after_content)
  end


end
