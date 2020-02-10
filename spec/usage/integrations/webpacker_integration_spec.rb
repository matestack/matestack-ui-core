describe "Webpacker integration", type: :feature, js: true do

  before(:all) do
    # Compile webpack javascripts
    result = `cd spec/dummy && yarn install && rake webpacker:compile`
    raise "rake webpacker:compile has failed." if result.include? "Error"
  end

  before do
    Rails.application.routes.draw do
      get '/webpack_test', to: 'webpack_test#my_action', as: 'webpack_test_action'
    end

    class WebpackTestController < ActionController::Base
      layout "application_with_webpack"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
      end
    end

    module Pages::WebpackTest
    end

    class Pages::WebpackTest::MyAction < Matestack::Ui::Page
      def response
        components {
          plain "Hello from matestack with webpacker"
        }
      end
    end
  end

  after do
    Rails.application.reload_routes!
  end

  specify "Matestack can be used in layouts that use a javascript_pack_tag (webpack) rather than the asset pipeline" do
    visit "/webpack_test"

    expect(page).to have_text "Hello from matestack with webpacker"
  end

  specify "MatestackUiCore is exposed to the global namespace" do
    visit "/webpack_test"
    expect(page).to have_text "Hello from matestack with webpacker"

    expect(page.evaluate_script("typeof MatestackUiCore")).to eq "object"
    expect(page.evaluate_script("typeof MatestackUiCore")).not_to eq "undefined"
    expect(page.evaluate_script("typeof MatestackUiCore.matestackEventHub")).to eq "object"
  end

end