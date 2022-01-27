require 'rails_core_spec_helper'
include CoreSpecUtils

describe "Layout Resolving", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "layout_resolving_spec" do
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

  it "does not wrap a Page with a layout when no Layout is explicitly specified" do

    class ExamplePage < Matestack::Ui::Page

      def response
        div do
          plain "hello from page"
        end
      end

    end

    class RenderTestAController < ActionController::Base
      layout "application_core"

      include Matestack::Ui::Core::Helper

      def example
        render ExamplePage
      end

    end

    visit "layout_resolving_spec/example_a"

    text = find(:xpath, '//body/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific Layout when explicitly specified on controller action level" do
    module ExampleApp
    end

    class ExampleApp::Layout < Matestack::Ui::Layout
      def response
        div class: "my-app-layout" do
          yield
        end
      end
    end

    class ExampleApp::SomeOtherExampleLayout < Matestack::Ui::Layout
      def response
        div class: "my-other-app-layout" do
          yield
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

    # otherwise the matestack_layout_class class var would be set as specified in the former spec
    class RenderTestBController < ActionController::Base
      layout "application_core"
      include Matestack::Ui::Core::Helper

      def example
        render ExamplePage, matestack_layout: ExampleApp::Layout
      end

      def second_example
        render ExamplePage, matestack_layout: ExampleApp::SomeOtherExampleLayout
      end
    end

    visit "layout_resolving_spec/example_b"
    text = find(:xpath, '//body/div[@class="my-app-layout"]/div[1]').text

    visit "layout_resolving_spec/second_example_b"
    text = find(:xpath, '//body/div[@class="my-other-app-layout"]/div[1]').text
    expect(text).to eq("hello from page")
  end

  it "wraps a Page with a specific Layout when explicitly specified on controller (top) level" do
    module ExampleApp
    end

    class ExampleApp::Layout < Matestack::Ui::Layout
      def response
        div class: "my-app-layout" do
          yield
        end
      end
    end

    class ExampleApp::SomeOtherExampleLayout < Matestack::Ui::Layout
      def response
        div class: "my-other-app-layout" do
          yield
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

    # otherwise the matestack_layout_class class var would be set as specified in the former spec
    class RenderTestCController < ActionController::Base
      include Matestack::Ui::Core::Helper
      layout "application_core"
      matestack_layout ExampleApp::Layout

      def example
        render ExamplePage
      end

      def second_example
        render ExamplePage, matestack_layout: ExampleApp::SomeOtherExampleLayout # top level defined app can be overwritten on action level
      end
    end

    visit "layout_resolving_spec/example_c"
    text = find(:xpath, '//body/div[@class="my-app-layout"]/div[1]').text

    visit "layout_resolving_spec/second_example_c"
    text = find(:xpath, '//body/div[@class="my-other-app-layout"]/div[1]').text
    expect(text).to eq("hello from page")

  end

  describe "is compatible with 0.7.x namespacing approach" do

    it "when app is defined on controller (top) level" do
      module Layouts end
      class Layouts::ExampleLayout < Matestack::Ui::Layout
        def response
          div class: "my-app-layout" do
            yield
          end
        end
      end

      class Layouts::SomeOtherExampleLayout < Matestack::Ui::Layout
        def response
          div class: "my-other-app-layout" do
            yield
          end
        end
      end

      module Pages end
      module Pages::ExampleLayout end
      module Pages::SomeOtherExampleLayout end

      class Pages::ExampleLayout::ExamplePage < Matestack::Ui::Page
        def response
          div do
            plain "hello from example page"
          end
        end
      end

      class Pages::SomeOtherExampleLayout::ExamplePage < Matestack::Ui::Page
        def response
          div do
            plain "hello from some other example page"
          end
        end
      end

      # otherwise the matestack_layout_class class var would be set as specified in the former spec

      class RenderTestEController < ActionController::Base
        include Matestack::Ui::Core::Helper
        layout "application_core"

        def example
          render Pages::ExampleLayout::ExamplePage, matestack_layout: Layouts::ExampleLayout
        end

        def second_example
          render Pages::SomeOtherExampleLayout::ExamplePage, matestack_layout: Layouts::SomeOtherExampleLayout
        end
      end

      visit "layout_resolving_spec/example_e"
      text = find(:xpath, '//body/div[@class="my-app-layout"]/div[1]').text

      visit "layout_resolving_spec/second_example_e"
      text = find(:xpath, '//body/div[@class="my-other-app-layout"]/div[1]').text
      expect(text).to eq("hello from some other example page")
    end

  end

end
