require_relative "../../../support/utils"
include Utils

describe "Render", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "render_app_resolving_spec" do
        get '/example_a', to: 'render_test_a#example'
        get '/second_example_a', to: 'render_test_a#second_example'
        get '/example_b', to: 'render_test_b#example'
        get '/second_example_b', to: 'render_test_b#second_example'
        get '/example_c', to: 'render_test_c#example'
        get '/second_example_c', to: 'render_test_c#second_example'
        get '/example_d', to: 'render_test_d#example'
        get '/second_example_d', to: 'render_test_d#second_example'
        get '/example_e', to: 'render_test_e#example'
        get '/second_example_e', to: 'render_test_e#second_example'
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

    # otherwise the matestack_app_class class var would be set as specified in the former spec
    class RenderTestAController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::Helper

      def example
        render ExamplePage
      end

    end

    visit "render_app_resolving_spec/example_a"

    # dom structure implies correct rendering with wrapping minimal app
    text = find(:xpath, 'id("matestack-ui")/div[@class="matestack-app-wrapper"]/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific App when explicitly specified on controller action level" do
    module ExampleApp
    end

    class ExampleApp::App < Matestack::Ui::App
      def response
        matestack do
          div class: "my-app-layout" do
            yield
          end
        end
      end
    end

    class SomeOtherExampleApp < Matestack::Ui::App
      def response
        matestack do
          div class: "my-other-app-layout" do
            yield
          end
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

    # otherwise the matestack_app_class class var would be set as specified in the former spec
    class RenderTestBController < ActionController::Base
      layout "application"
      include Matestack::Ui::Core::Helper

      def example
        render ExamplePage, matestack_app: ExampleApp::App
      end

      def second_example
        render ExamplePage, matestack_app: SomeOtherExampleApp
      end
    end

    visit "render_app_resolving_spec/example_b"
    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text

    visit "render_app_resolving_spec/second_example_b"
    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-other-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific App when explicitly specified on controller (top) level" do
    module ExampleApp
    end

    class ExampleApp::App < Matestack::Ui::App
      def response
        matestack do
          div class: "my-app-layout" do
            yield
          end
        end
      end
    end

    class SomeOtherExampleApp < Matestack::Ui::App
      def response
        matestack do
          div class: "my-other-app-layout" do
            yield
          end
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

    # otherwise the matestack_app_class class var would be set as specified in the former spec
    class RenderTestCController < ActionController::Base
      include Matestack::Ui::Core::Helper
      layout "application"
      matestack_app ExampleApp::App

      def example
        render ExamplePage
      end

      def second_example
        render ExamplePage, matestack_app: SomeOtherExampleApp # top level defined app can be overwritten on action level
      end
    end

    visit "render_app_resolving_spec/example_c"
    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
    expect(text).to eq("hello from page")

    visit "render_app_resolving_spec/second_example_c"
    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-other-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "does not wrap a Page with an App when explicitly set to false" do

    class ExamplePage < Matestack::Ui::Page
      def response
        matestack do
          div do
            plain "hello from page"
          end
        end
      end
    end

    # otherwise the matestack_app_class class var would be set as specified in the former spec
    class RenderTestDController < ActionController::Base
      include Matestack::Ui::Core::Helper
      layout "application"

      def example
        render ExamplePage # should be wrapped by a minimal default
      end

      def second_example
        render ExamplePage, matestack_app: false # should not be wrapped by an app at all
      end
    end

    visit "render_app_resolving_spec/example_d"
    # dom structure implies correct rendering with wrapping specified app
    text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="matestack-page-container"]//div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
    expect(text).to eq("hello from page")

    visit "render_app_resolving_spec/second_example_d"
    # dom structure implies correct rendering without app
    text = find(:xpath, '//div[@class="matestack-page-root"]/div').text
    expect(text).to eq("hello from page")
  end

  describe "is compatible with 0.7.x namespacing approach" do

    it "when app is defined on controller (top) level" do
      module Apps end
      class Apps::ExampleApp < Matestack::Ui::App
        def response
          matestack do
            div class: "my-app-layout" do
              yield
            end
          end
        end
      end

      class Apps::SomeOtherExampleApp < Matestack::Ui::App
        def response
          matestack do
            div class: "my-other-app-layout" do
              yield
            end
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

      class RenderTestEController < ActionController::Base
        include Matestack::Ui::Core::Helper
        layout "application"

        def example
          render Pages::ExampleApp::ExamplePage, matestack_app: Apps::ExampleApp
        end

        def second_example
          render Pages::SomeOtherExampleApp::ExamplePage, matestack_app: Apps::SomeOtherExampleApp
        end
      end

      visit "render_app_resolving_spec/example_e"
      # dom structure implies correct rendering with wrapping specified app
      text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
      expect(text).to eq("hello from example page")

      visit "render_app_resolving_spec/second_example_e"
      # dom structure implies correct rendering with wrapping specified app
      text = find(:xpath, 'id("matestack-ui")//div[@class="matestack-app-wrapper"]/div[@class="my-other-app-layout"]//div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]/div/div[@class="matestack-page-root"]/div[1]').text
      expect(text).to eq("hello from some other example page")
    end

  end

end
