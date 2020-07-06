require_relative "../../../../support/utils"
include Utils

describe "Render", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "render_app_resolving_spec" do
        get '/example', to: 'render_test#example'
        get '/second_example', to: 'render_test#second_example'
      end
    end
    Rails.application.reload_routes!
  end

  it "wraps a Page with a minimal default App when no App is explicitly specified" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "hello from page"
        end
      end

    end

    class RenderTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def example
        render ExamplePage
      end

    end

    visit "render_app_resolving_spec/example"

    # dom structure implies correct rendering with wrapping minimal app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific App when explicitly specified on controller action level" do

    class ExampleApp < Matestack::Ui::App

      def response
        div class: "my-app-layout" do
          page_content
        end
      end

    end

    class SomeOtherExampleApp < Matestack::Ui::App

      def response
        div class: "my-other-app-layout" do
          page_content
        end
      end

    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "hello from page"
        end
      end

    end

    class RenderTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def example
        render ExamplePage, matestack_app: ExampleApp
      end

      def second_example
        render ExamplePage, matestack_app: SomeOtherExampleApp
      end

    end

    visit "render_app_resolving_spec/example"

    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text

    visit "render_app_resolving_spec/second_example"

    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-other-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific App when explicitly specified on controller (top) level" do

    class ExampleApp < Matestack::Ui::App

      def response
        div class: "my-app-layout" do
          page_content
        end
      end

    end

    class SomeOtherExampleApp < Matestack::Ui::App

      def response
        div class: "my-other-app-layout" do
          page_content
        end
      end

    end

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "hello from page"
        end
      end

    end

    class RenderTestController < ActionController::Base
      include Matestack::Ui::Core::ApplicationHelper

      layout "application"
      matestack_app ExampleApp


      def example
        render ExamplePage
      end

      def second_example
        render ExamplePage, matestack_app: SomeOtherExampleApp # top level defined app can be overwritten on action level
      end

    end

    visit "render_app_resolving_spec/example"

    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
    expect(text).to eq("hello from page")
    visit "render_app_resolving_spec/second_example"

    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-other-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "does not wrap a Page with an App when explicitly set to false" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "hello from page"
        end
      end

    end

    # otherwise the matestack_app_class class var would be set as specified in the former spec
    Object.send(:remove_const, :RenderTestController) if defined?(RenderTestController)
    class RenderTestController < ActionController::Base
      include Matestack::Ui::Core::ApplicationHelper

      layout "application"


      def example
        render ExamplePage # should be wrapped by a minimal default
      end

      def second_example
        render ExamplePage, matestack_app: false # should not be wrapped by an app at all
      end

    end

    visit "render_app_resolving_spec/example"

    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
    expect(text).to eq("hello from page")

    visit "render_app_resolving_spec/second_example"
    # sleep

    # dom structure implies correct rendering without app
    text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_page"]/div').text
    expect(text).to eq("hello from page")
  end

  describe "is compatible with 0.7.x namespacing approach" do

    it "when app is defined on controller (top) level" do

      module Apps end
      class Apps::ExampleApp < Matestack::Ui::App

        def response
          div class: "my-app-layout" do
            page_content
          end
        end

      end

      class Apps::SomeOtherExampleApp < Matestack::Ui::App

        def response
          div class: "my-other-app-layout" do
            page_content
          end
        end

      end

      module Pages end
      module Pages::ExampleApp end
      module Pages::SomeOtherExampleApp end

      class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

        def response
          div do
            plain "hello from example page"
          end
        end

      end

      class Pages::SomeOtherExampleApp::ExamplePage < Matestack::Ui::Page

        def response
          div do
            plain "hello from some other example page"
          end
        end

      end

      # otherwise the matestack_app_class class var would be set as specified in the former spec
      Object.send(:remove_const, :RenderTestController) if defined?(RenderTestController)
      class RenderTestController < ActionController::Base

        include Matestack::Ui::Core::ApplicationHelper
        layout "application"

        def example
          render Pages::ExampleApp::ExamplePage, matestack_app: Apps::ExampleApp
        end

        def second_example
          render Pages::SomeOtherExampleApp::ExamplePage,   matestack_app: Apps::SomeOtherExampleApp
        end

      end

      visit "render_app_resolving_spec/example"

      # dom structure implies correct rendering with wrapping specified app
      text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
      expect(text).to eq("hello from example page")

      visit "render_app_resolving_spec/second_example"

      # dom structure implies correct rendering with wrapping specified app
      text = find(:xpath, 'id("matestack_ui")/div[@class="matestack_app"]/div[@class="my-other-app-layout"]/div[@class="matestack_page_content"]/div[1]/div[@class="matestack_page"]/div[1]').text
      expect(text).to eq("hello from some other example page")
    end

  end

end
