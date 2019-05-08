require_relative "../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it "Example 1 - Rerender on event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          async rerender_on: "my_event" do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')

    element = page.find("#my-div")
    after_content = element.text

    expect(before_content).not_to eq(after_content)
  end

  it "Example 1.1 - Rerender on event if wrapped in app" do

    class Apps::ExampleApp < App::Cell::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          main do
            page_content
          end
        }
      end

    end

    module Pages::ExampleApp

    end


    class Pages::ExampleApp::ExamplePage < Page::Cell::Page

      def response
        components {
          async rerender_on: "my_event" do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    class AsyncInAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def example
        responder_for(Pages::ExampleApp::ExamplePage)
      end

    end

    Rails.application.routes.append do
      get 'async_specs/in_app/example', to: 'async_in_app_pages#example', as: 'asyn_in_app_example'
    end
    Rails.application.reload_routes!

    visit "/async_specs/in_app/example"

    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')

    element = page.find("#my-div")
    after_content = element.text

    expect(before_content).not_to eq(after_content)
  end

  it "Example 2 - Show on event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          async show_on: "my_event" do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')

    expect(page).to have_selector "#my-div"
  end

  it "Example 3 - Hide on event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          async hide_on: "my_event" do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')

    expect(page).not_to have_selector "#my-div"
  end

  it "Example 3 - hide after show on event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          async show_on: "my_event", hide_after: 1000 do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).not_to have_selector "#my-div"
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_selector "#my-div"
    sleep 1
    expect(page).not_to have_selector "#my-div"

  end

  it "Example 4: show on event with event payload" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          async show_on: "my_event" do
            div id: "my-div" do
              plain "{{event.data.message}}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).not_to have_content "test!"
    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event", { message: "test!" })')
    expect(page).to have_content "test!"

  end

end
