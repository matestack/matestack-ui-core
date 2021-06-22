require_relative "../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "page_rendering_components_spec" do
        get '/page_rendering_test', to: 'page_rendering_test#my_action'
      end
    end
    Rails.application.reload_routes!

    class ExamplePageRendering < Matestack::Ui::Page
      def response
        div do
          plain "ExamplePage"
        end
      end
    end

    class PageRenderingTestController < ActionController::Base
      include Matestack::Ui::Core::Helper

      def my_action
        render ExamplePageRendering
      end
    end
  end

  before :each do
    visit "page_rendering_components_spec/page_rendering_test"
  end

  it "wraps content with a specific dom structure" do
    expect(page).to have_xpath('//div[@id="matestack-ui"]/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
  end

  it "renders its root element with a dynamic id composed of {controller} and {action}" do
    expect(page).to have_xpath('//div[@id="matestack-page-page-rendering-test-my-action"]')
  end

  it "renders its root element with a specific class" do
    expect(page).to have_xpath('//div[@class="matestack-page-root"]')
  end
end
