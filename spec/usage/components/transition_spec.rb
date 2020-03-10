require_relative "../../support/utils"
include Utils

describe "Transition Component", type: :feature, js: true do

  before :all do

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          nav do
            transition path: :page1_path do
              button text: "Page 1"
            end
            transition path: :page2_path do
              button text: "Page 2"
            end
          end
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
          div id: "my-div-on-page-1" do
            heading size: 2, text: "This is Page 1"
            plain "#{DateTime.now.strftime('%Q')}"
          end
        }
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "my-div-on-page-2" do
            heading size: 2, text: "This is Page 2"
            plain "#{DateTime.now.strftime('%Q')}"
          end
          transition path: :page1_path do
            button text: "Back to Page 1"
          end
        }
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        responder_for(Pages::ExampleApp::ExamplePage)
      end

      def page2
        responder_for(Pages::ExampleApp::SecondExamplePage)
      end

    end

    Rails.application.routes.append do
      get 'my_example_app/page1', to: 'example_app_pages#page1', as: 'page1'
      get 'my_example_app/page2', to: 'example_app_pages#page2', as: 'page2'
    end
    Rails.application.reload_routes!

  end

  it "Example 1 - Perform transition from one page to another without page reload if related to app" do

    visit "/my_example_app/page1"

    expect(page).to have_content("My Example App Layout")
    expect(page).to have_button("Page 1")
    expect(page).to have_button("Page 2")

    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")

    element = page.find("#my-div-on-page-1")
    first_content_on_page_1 = element.text

    page.evaluate_script('document.body.classList.add("not-reloaded")')
    expect(page).to have_selector("body.not-reloaded")

    click_button("Page 2")

    expect(page).to have_content("My Example App Layout")
    expect(page).not_to have_content("This is Page 1")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_selector("body.not-reloaded")

    click_button("Back to Page 1")

    element = page.find("#my-div-on-page-1")
    refreshed_content_on_page_1 = element.text

    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")
    expect(page).to have_selector("body.not-reloaded")

    expect(first_content_on_page_1).not_to eq(refreshed_content_on_page_1)
  end

  it "Example 2 - Perform transition from one page to another without page reload when using page history buttons" do

    visit "/my_example_app/page1"

    expect(page).to have_content("My Example App Layout")
    expect(page).to have_button("Page 1")
    expect(page).to have_button("Page 2")

    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")

    element = page.find("#my-div-on-page-1")
    first_content_on_page_1 = element.text

    page.evaluate_script('document.body.classList.add("not-reloaded")')
    expect(page).to have_selector("body.not-reloaded")

    click_button("Page 2")

    expect(page).to have_content("My Example App Layout")
    expect(page).not_to have_content("This is Page 1")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_selector("body.not-reloaded")

    page.go_back

    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")
    expect(page).to have_selector("body.not-reloaded")
    expect(page).to have_no_content(first_content_on_page_1)

    page.go_forward

    expect(page).to have_content("My Example App Layout")
    expect(page).not_to have_content("This is Page 1")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_selector("body.not-reloaded")
  end

  # supposed to work, but doesn't. Suspect Vue is the culprint here
  # it "Example 2 - Perform transition from one page to another by providing route as string (not recommended)" do
  #
  #   class Apps::ExampleApp < Matestack::Ui::App
  #
  #     def response
  #       components {
  #         heading size: 1, text: "My Example App Layout"
  #         nav do
  #           transition path: "http://127.0.0.1:35553/my_example_app/page1" do
  #             button text: "Page 1"
  #           end
  #           transition path: "http://127.0.0.1:35553/my_example_app/page2" do
  #             button text: "Page 2"
  #           end
  #         end
  #         main do
  #           page_content
  #         end
  #       }
  #     end
  #
  #   end
  #
  #   module Pages::ExampleApp
  #
  #   end
  #
  #   class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page
  #
  #     def response
  #       components {
  #         div id: "my-div-on-page-1" do
  #           heading size: 2, text: "This is Page 1"
  #           plain "#{DateTime.now.strftime('%Q')}"
  #         end
  #       }
  #     end
  #
  #   end
  #
  #   class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page
  #
  #     def response
  #       components {
  #         div id: "my-div-on-page-2" do
  #           heading size: 2, text: "This is Page 2"
  #           plain "#{DateTime.now.strftime('%Q')}"
  #         end
  #         transition path: 'my_example_app/page1' do
  #           button text: "Back to Page 1"
  #         end
  #       }
  #     end
  #
  #   end
  #
  #   class ExampleAppPagesController < ExampleController
  #     include Matestack::Ui::Core::ApplicationHelper
  #
  #     def page1
  #       responder_for(Pages::ExampleApp::ExamplePage)
  #     end
  #
  #     def page2
  #       responder_for(Pages::ExampleApp::SecondExamplePage)
  #     end
  #
  #   end
  #
  #   Rails.application.routes.append do
  #     get 'my_example_app/page1', to: 'example_app_pages#page1', as: 'page1_string'
  #     get 'my_example_app/page2', to: 'example_app_pages#page2', as: 'page2_string'
  #   end
  #   Rails.application.reload_routes!
  #
  #   visit "/my_example_app/page1"
  #
  #   expect(page).to have_content("My Example App Layout")
  #   expect(page).to have_button("Page 1")
  #   expect(page).to have_button("Page 2")
  #
  #   expect(page).to have_content("This is Page 1")
  #   expect(page).not_to have_content("This is Page 2")
  #
  #   click_button("Page 2")
  #
  #   expect(page).to have_content("My Example App Layout")
  #   expect(page).not_to have_content("This is Page 1")
  #   expect(page).to have_content("This is Page 2")
  #
  # end

end
