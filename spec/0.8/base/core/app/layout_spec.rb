require_relative "../../../../support/utils"
include Utils

describe "App", type: :feature, js: true do

  before :all do

    Rails.application.routes.append do
      scope "app_layout_spec" do
        get 'page1', to: 'example_app_pages#page1', as: 'page1'
        get 'page2', to: 'example_app_pages#page2', as: 'page2'
      end
    end
    Rails.application.reload_routes!

  end

  it "can wrap pages with a layout" do

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        heading size: 1, text: "My Example App Layout"
        main do
          page_content
        end
      end

    end

    module Pages::ExampleApp

    end

    class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

      def response
        div id: "my-div-on-page-1" do
          heading size: 2, text: "This is Page 1"
        end
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

      def response
        div id: "my-div-on-page-2" do
          heading size: 2, text: "This is Page 2"
        end
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        render Pages::ExampleApp::ExamplePage
      end

      def page2
        render Pages::ExampleApp::SecondExamplePage
      end

    end

    visit "app_layout_spec/page1"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page_content"]/div/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')

    visit "app_layout_spec/page2"

    expect(page).to have_xpath('//div[@class="matestack_app"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="matestack_app"]/main/div[@class="matestack_page_content"]/div/div[@id="my-div-on-page-2"]/h2[contains(.,"This is Page 2")]')
  end

end
