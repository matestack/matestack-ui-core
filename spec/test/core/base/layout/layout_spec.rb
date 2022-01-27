require 'rails_core_spec_helper'
include CoreSpecUtils

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

    class ExampleApp::App < Matestack::Ui::Layout
      def response
        div class: "root-div-from-layout" do
          h1 "My Example App Layout", size: 1
          main do
            yield
          end
        end
      end
    end

    module ExampleApp::Pages
    end

    class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-1" do
          h2 "This is Page 1", size: 2
        end
      end
    end

    class ExampleApp::Pages::SecondExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-2" do
          h2 "This is Page 2", size: 2
        end
      end
    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::Helper
      matestack_layout ExampleApp::App

      def page1
        render ExampleApp::Pages::ExamplePage
      end

      def page2
        render ExampleApp::Pages::SecondExamplePage
      end
    end

    visit "app_layout_spec/layout_page1"
    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/main/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')
    visit "app_layout_spec/layout_page2"
    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/main/div[@id="my-div-on-page-2"]/h2[contains(.,"This is Page 2")]')
  end

  it 'can use a layout file' do
    module ExampleApp
    end

    class ExampleApp::App < Matestack::Ui::Layout
      layout 'application_core'

      def response
        div class: "root-div-from-layout" do
          h1 "My Example App Layout", size: 1
          main do
            yield
          end
        end
      end
    end

    module ExampleApp::Pages
    end

    class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page
      def response
        div id: "my-div-on-page-1" do
          h2 "This is Page 1", size: 2
        end
      end
    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::Helper
      layout false
      matestack_layout ExampleApp::App

      def page1
        render ExampleApp::Pages::ExamplePage
      end
    end

    visit "app_layout_spec/layout_page1"

    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/h1[contains(.,"My Example App Layout")]')
    expect(page).to have_xpath('//div[@class="root-div-from-layout"]/main/div[@id="my-div-on-page-1"]/h2[contains(.,"This is Page 1")]')
    expect(page).to have_selector('div#from-rails-core-layout', visible: false)
  end

end
