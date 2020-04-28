require_relative "../../support/utils"
include Utils

describe "App", type: :feature, js: true do

  before :all do

    Rails.application.routes.append do
      get 'app_specs/my_example_app/page1', to: 'example_app_pages#page1', as: 'app_specs_page1'
      get 'app_specs/my_example_app/page2', to: 'example_app_pages#page2', as: 'app_specs_page2'
    end
    Rails.application.reload_routes!

  end

  it "can wrap pages with a layout" do

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
          div id: "my-div-on-page-1" do
            heading size: 2, text: "This is Page 1"
          end
        }
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "my-div-on-page-2" do
            heading size: 2, text: "This is Page 2"
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

    visit "app_specs/my_example_app/page1"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page"]/div/div[@class="matestack_page_content"]/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')

    visit "app_specs/my_example_app/page2"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page"]/div/div[@class="matestack_page_content"]/div[@id="my-div-on-page-2"]/h2[contains(.,"This is Page 2")]')

  end

  it "enables transitions between pages without page reload" do

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          nav do
            transition path: :app_specs_page1_path do
              button text: "Page 1"
            end
            transition path: :app_specs_page2_path do
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
          end
        }
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "my-div-on-page-2" do
            heading size: 2, text: "This is Page 2"
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

    visit "app_specs/my_example_app/page1"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page"]/div/div[@class="matestack_page_content"]/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')

    click_button "Page 2"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page"]/div/div[@class="matestack_page_content"]/div[@id="my-div-on-page-2"]/h2[contains(.,"This is Page 2")]')

  end

  it "has access to view context" do

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          if @view_context.view_renderer.instance_of?(ActionView::Renderer)
            plain "has access to ActionView Context"
          end
          plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
          plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
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
          end
        }
      end

    end


    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        responder_for(Pages::ExampleApp::ExamplePage)
      end

    end

    visit "app_specs/my_example_app/page1"

    expect(page).to have_content("has access to ActionView Context")
    expect(page).to have_content("Test Link")
    expect(page).to have_content("3 minutes")

  end

  it "can navigate back using browser history"

  it "just uses serverside routes, which works standalone"

end
