require_relative "../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it "Example 1 - Rerender on event on page-level" do

    class ExamplePage < Matestack::Ui::Page

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

  it "Example 1.1 - Rerender on event on (nested) component-level" do

    module Components end
    module Components::Some end
    module Components::Other end

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div do
            custom_some_component
          end
        }
      end

    end

    class Components::Some::Component < Matestack::Ui::StaticComponent

      def response
        components {
          div id: "static-content-on-component" do
            plain "Component 1: #{DateTime.now.strftime('%Q')}"
          end
          async rerender_on: "my_event" do
            div id: "dynamic-content-on-component" do
              plain "Component 1: #{DateTime.now.strftime('%Q')}"
            end
          end
          async rerender_on: "my_other_event" do
            custom_other_component
            div id: "other-dynamic-content-on-component" do
              plain "Component 1: #{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    class Components::Other::Component < Matestack::Ui::StaticComponent

      def response
        components {
          div id: "static-content-on-other-component" do
            plain "Component 2: #{DateTime.now.strftime('%Q')}"
          end
          async rerender_on: "my_event" do
            div id: "dynamic-content-on-other-component" do
              plain "Component 2: #{DateTime.now.strftime('%Q')}"
            end
          end
          async rerender_on: "my_other_event" do
            div id: "other-dynamic-content-on-other-component" do
              plain "Component 2: #{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end


    visit "/example"

    static_content_before = page.find("#static-content-on-component").text
    dynamic_content_before = page.find("#dynamic-content-on-component").text
    other_dynamic_content_before = page.find("#other-dynamic-content-on-component").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    # sleep
    static_content_after = page.find("#static-content-on-component").text
    dynamic_content_after = page.find("#dynamic-content-on-component").text
    other_dynamic_content_after = page.find("#other-dynamic-content-on-component").text

    expect(static_content_before).to eq(static_content_after)
    expect(dynamic_content_before).not_to eq(dynamic_content_after)
    expect(other_dynamic_content_before).to eq(other_dynamic_content_after)
  end

  it "Example 1.2 - Rerender on event on page-level if wrapped in app" do

    class Apps::ExampleApp < Matestack::Ui::App

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


    class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

  it "Example 3.1 - Show on / Hide on combination init not shown by default" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          async show_on: "my_show_event", hide_on: "my_hide_event" do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_show_event")')

    expect(page).to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_hide_event")')

    expect(page).not_to have_selector "#my-div"
  end

  it "Example 3.2 - Show on / Hide on combination init shown if configured" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          async show_on: "my_show_event", hide_on: "my_hide_event", init_show: true do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        }
      end

    end

    visit "/example"

    expect(page).to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_hide_event")')

    expect(page).not_to have_selector "#my-div"

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_show_event")')

    expect(page).to have_selector "#my-div"
  end


  it "Example 3.3 - hide after show on event" do

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

  describe "defer" do

    it "Example 5: deferred loading without any timeout, deferred request right after component mounting" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @current_time = DateTime.now.strftime('%Q')
        end

        def response
          components {
            div id: "my-reference-div" do
              plain "#{@current_time}"
            end
            async do
              div id: "my-not-deferred-div" do
                plain "#{@current_time}"
              end
            end
            async defer: true do
              div id: "my-deferred-div" do
                plain "#{@current_time}"
              end
            end
          }
        end

      end

      visit "/example"

      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load

      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading

      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp

      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(0, 2000).inclusive

    end

    it "Example 6: deferred loading with a specific timeout" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @current_time = DateTime.now.strftime('%Q')
        end

        def response
          components {
            div id: "my-reference-div" do
              plain "#{@current_time}"
            end
            async do
              div id: "my-not-deferred-div" do
                plain "#{@current_time}"
              end
            end
            async defer: 1000 do
              div id: "my-deferred-div" do
                plain "#{@current_time}"
              end
            end
          }
        end

      end

      visit "/example"

      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load

      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading

      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(1000, 3000).inclusive

    end

    it "Example 7: multiple deferred loadings with a specific timeout" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @current_time = DateTime.now.strftime('%Q')
        end

        def response
          components {
            div id: "my-reference-div" do
              plain "#{@current_time}"
            end
            async do
              div id: "my-not-deferred-div" do
                plain "#{@current_time}"
              end
            end
            async defer: 1000 do
              div id: "my-deferred-div" do
                plain "#{@current_time}"
              end
            end
            async defer: 2000 do
              div id: "my-second-deferred-div" do
                plain "#{@current_time}"
              end
            end
          }
        end

      end

      visit "/example"

      initial_timestamp = page.find("#my-reference-div").text #initial page load
      non_deferred_timestamp = page.find("#my-not-deferred-div").text #initial page load

      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading
      second_deferred_timestamp = page.find("#my-second-deferred-div").text #deferred loading

      expect(non_deferred_timestamp).to eq initial_timestamp
      expect(deferred_timestamp).to be > initial_timestamp
      expect(second_deferred_timestamp).to be > initial_timestamp
      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(1000, 3000).inclusive
      expect(second_deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(2000, 4000).inclusive

    end

    it "Example 8: deferred loading without any timeout, triggered by on_show event" do

      class ExamplePage < Matestack::Ui::Page

        def prepare
          @current_time = DateTime.now.strftime('%Q')
        end

        def response
          components {
            div id: "my-reference-div" do
              plain "#{@current_time}"
            end
            onclick emit: "my_event" do
              button text: "show"
            end
            onclick emit: "my_other_event" do
              button text: "hide"
            end
            async defer: true, show_on: "my_event", hide_on: "my_other_event" do
              plain "waited for 'my_event'"
              div id: "my-deferred-div" do
                plain "#{@current_time}"
              end
            end
          }
        end

      end

      visit "/example"

      initial_timestamp = page.find("#my-reference-div").text #initial page load

      expect(page).not_to have_content("waited for 'my_event'")

      sleep 2

      click_button "show"

      expect(page).to have_content("waited for 'my_event'")

      deferred_timestamp = page.find("#my-deferred-div").text #deferred loading after click

      expect(deferred_timestamp.to_i - initial_timestamp.to_i).to be_between(2000, 4000).inclusive

      sleep 1

      click_button "hide"
      click_button "show"

      new_deferred_timestamp = page.find("#my-deferred-div").text #deferred loading after another click

      expect(new_deferred_timestamp.to_i - deferred_timestamp.to_i).to be_between(1000, 2000).inclusive

    end

  end

end
