require_relative "../../../../support/utils"
include Utils

describe "App", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "app_layout_spec" do
        get 'layout_page1', to: 'example_app_pages#page1', as: 'layout_page1'
        get 'layout_page2', to: 'example_app_pages#page2', as: 'layout_page2'
      end
    end
    Rails.application.reload_routes!
  end

  it "can wrap pages with a layout" do
    module ExampleApp
    end

    class ExampleApp::App < Matestack::Ui::App
      def response
        heading size: 1, text: "My Example App Layout"
        main do
          page_content
        end
      end
    end

    module ExampleApp::Pages
    end

    class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-1" do
          heading size: 2, text: "This is Page 1"
        end
      end
    end

    class ExampleApp::Pages::SecondExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-2" do
          heading size: 2, text: "This is Page 2"
        end
      end
    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper
      matestack_app ExampleApp::App

      def page1
        render ExampleApp::Pages::ExamplePage
      end

      def page2
        render ExampleApp::Pages::SecondExamplePage
      end
    end

    visit "app_layout_spec/layout_page1"

    expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page"]/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')

    visit "app_layout_spec/layout_page2"
    expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page"]/div[@id="my-div-on-page-2"]/h2[contains(.,"This is Page 2")]')
  end

end
