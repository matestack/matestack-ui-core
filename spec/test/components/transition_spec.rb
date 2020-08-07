require_relative "../support/utils"
include Utils

describe "Transition Component", type: :feature, js: true do

  before :all do
    module Example
    end

    class Example::App < Matestack::Ui::App
      def response
        heading size: 1, text: "My Example App Layout"
        nav do
          transition path: :page1_path do
            button text: "Page 1"
          end
          transition path: :page2_path, params: {some_other_param: "bar" } do
            button text: "Page 2"
          end
          transition path: :page3_path, delay: 1500 do
            button text: "Page 3"
          end
        end
        main do
          page_content
        end
        toggle show_on: "page_loading_triggered" do
          plain "started a transition"
        end
      end
    end

    module Example::Pages
    end

    class Example::Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-1" do
          heading size: 2, text: "This is Page 1"
          plain "#{DateTime.now.strftime('%Q')}"
          plain "#{context[:params][:some_param]}"
        end
      end
    end

    class Example::Pages::SecondExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-2" do
          heading size: 2, text: "This is Page 2"
          plain "#{DateTime.now.strftime('%Q')}"
        end
        transition path: :page1_path do
          button text: "Back to Page 1"
          plain "#{context[:params][:some_other_param]}"
        end
        transition path: :sub_page2_path do
          button text: "Sub Page 2"
        end
      end
    end

    class Example::Pages::SubSecondExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-2" do
          heading size: 2, text: "This is a Subpage of Page 2"
          plain "#{DateTime.now.strftime('%Q')}"
        end
        transition path: :page1_path do
          button text: "Back to Page 1"
          plain "#{context[:params][:some_other_param]}"
        end
      end
    end

    class Example::Pages::ThirdExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-3" do
          heading size: 2, text: "This is Page 3"
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper
      matestack_app Example::App

      def page1
        render(Example::Pages::ExamplePage)
      end

      def page2
        render(Example::Pages::SecondExamplePage)
      end

      def sub_page2
        render(Example::Pages::SubSecondExamplePage)
      end

      def page3
        render(Example::Pages::ThirdExamplePage)
      end
    end

    Rails.application.routes.append do
      get 'my_example_app/page1', to: 'example_app_pages#page1', as: 'page1'
      get 'my_example_app/page2', to: 'example_app_pages#page2', as: 'page2'
      get 'my_example_app/page2/sub_page2', to: 'example_app_pages#sub_page2', as: 'sub_page2'
      get 'my_example_app/page3', to: 'example_app_pages#page3', as: 'page3'
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

  it "Example 3 - Perform transition from one page to another without page reload when using page history buttons" do
    visit "/my_example_app/page1?some_param=foo"
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_button("Page 1")
    expect(page).to have_button("Page 2")
    expect(page).to have_content("This is Page 1")
    expect(page).to have_content("foo")
    expect(page).not_to have_content("This is Page 2")
    element = page.find("#my-div-on-page-1")
    first_content_on_page_1 = element.text
    page.evaluate_script('document.body.classList.add("not-reloaded")')
    expect(page).to have_selector("body.not-reloaded")

    click_button("Page 2")
    expect(page).to have_content("My Example App Layout")
    expect(page).not_to have_content("This is Page 1")
    expect(page).not_to have_content("foo")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_content("bar")
    expect(page).to have_selector("body.not-reloaded")

    page.go_back
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).to have_content("foo")
    expect(page).not_to have_content("This is Page 2")
    expect(page).not_to have_content("bar")
    expect(page).to have_selector("body.not-reloaded")
    expect(page).to have_no_content(first_content_on_page_1)

    page.go_forward
    expect(page).to have_content("My Example App Layout")
    expect(page).not_to have_content("This is Page 1")
    expect(page).not_to have_content("foo")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_content("bar")
    expect(page).to have_selector("body.not-reloaded")
  end

  it "Example 4 - Sets active class on clientside when target path is current path " do
    visit "/my_example_app/page1"
    sleep 1
    link = find('a.active')
    expect(link.text).to eq("Page 1")

    click_button("Page 2")
    sleep 1
    link = find('a.active')
    expect(link.text).to eq("Page 2")

    # query params should not disturb active class
    visit "/my_example_app/page1?some_param=foo"
    link = find('a.active')
    expect(link.text).to eq("Page 1")

    # active sub page sets special active class on parent
    visit "/my_example_app/page2"
    sleep 1
    link = find('a.active')
    expect(link.text).to eq("Page 2")

    click_button("Sub Page 2")
    sleep 1
    link = find('a.active-child')
    expect(link.text).to eq("Page 2")
  end

  it "Example 5 - Delay Transition" do
    visit "/my_example_app/page1"
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")
    element = page.find("main")
    before_content = element.text
    page.evaluate_script('document.body.classList.add("not-reloaded")')

    click_button("Page 3")
    element = page.find("main")
    after_content = element.text
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_selector("body.not-reloaded")
    expect(before_content).to eq(after_content) # still the same content as we delayed the transition
    sleep 2
    element = page.find("main")
    after_content = element.text
    expect(before_content).not_to eq(after_content)
    expect(page).to have_content("This is Page 3")
    expect(page).to have_selector("body.not-reloaded")
  end

  it "Example 6 - Emits event on transition triggering" do
    visit "/my_example_app/page1"
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")
    expect(page).not_to have_content("started a transition")
    page.evaluate_script('document.body.classList.add("not-reloaded")')

    click_button("Page 2")
    expect(page).to have_content("started a transition")
    expect(page).to have_content("My Example App Layout")
    expect(page).to have_selector("body.not-reloaded")
    expect(page).not_to have_content("This is Page 1")
    expect(page).to have_content("This is Page 2")
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
  #   module Example::Pages
  #
  #   end
  #
  #   class Example::Pages::ExamplePage < Matestack::Ui::Page
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
  #   class Example::Pages::SecondExamplePage < Matestack::Ui::Page
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
  #       render(Example::Pages::ExamplePage)
  #     end
  #
  #     def page2
  #       render(Example::Pages::SecondExamplePage)
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
