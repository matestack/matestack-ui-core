require_relative "../../../support/utils"
include Utils

describe "Async Component", type: :feature, js: true do

  it "rerender on event(s) on page-level" do
    class ExamplePage < Matestack::Ui::Page
      def response
        async rerender_on: "my_event", id: 'async-first' do
          div id: "my-div" do
            plain "1: #{DateTime.now.strftime('%Q')}"
          end
        end
        some_partial
      end

      def some_partial
        async rerender_on: "multi_event_1, multi_event_2", id: 'async-second' do
          div id: "my-second-div" do
            plain "2: #{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    visit "/example"
    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_content(before_content)
    element = page.find("#my-second-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_1")')
    expect(page).not_to have_content(before_content)
    element = page.find("#my-second-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event_2")')
    expect(page).not_to have_content(before_content)
  end

  it "rerender on event behind yield" do
    class ExamplePage < Matestack::Ui::Page
      def response
        div do
          some_component do
            async rerender_on: "my_event", id: 'async-example-page' do
              div id: "yielded-async-1" do
                plain "yielded timestamp 1: #{DateTime.now.strftime('%Q')}"
              end
            end
          end
        end
      end
    end

    class SomeComponent < Matestack::Ui::Component
      def response
        div id: "yielded-content-1" do
          yield
        end
        other_component do
          async rerender_on: "my_other_event", id: 'async-some-component' do
            div id: "nested-yielded-async-2" do
              plain "yielded timestamp 2: #{DateTime.now.strftime('%Q')}"
            end
          end
        end
      end

      register_self_as(:some_component)
    end

    class OtherComponent < Matestack::Ui::Component
      def response
        div id: "nested-yielded-content-2" do
          yield
        end
      end

      register_self_as(:other_component)
    end

    visit "/example"
    content_before = page.find("#yielded-async-1").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_content(content_before)
    within "#yielded-content-1" do
      expect(page).to have_content("yielded timestamp 1: ")
    end
    content_before = page.find("#nested-yielded-async-2").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_other_event")')
    expect(page).not_to have_content(content_before)
    within "#nested-yielded-content-2" do
      expect(page).to have_content("yielded timestamp 2: ")
    end
  end

  it "rerender on event on (nested) component-level" do
    class ExamplePage < Matestack::Ui::Page
      def response
        div do
          some_component
        end
      end
    end

    class SomeComponent < Matestack::Ui::Component
      def response
        div id: "static-content-on-component" do
          plain "Component 1.1: #{DateTime.now.strftime('%Q')}"
        end
        async rerender_on: "my_event", id: 'async-some-component' do
          div id: "dynamic-content-on-component" do
            plain "Component 1.2: #{DateTime.now.strftime('%Q')}"
          end
        end
        some_partial
      end

      def some_partial
        async rerender_on: "my_other_event, some_other_event", id: 'async-some-component-partial' do
          div id: "other-dynamic-content-on-component" do
            plain "Component 1.3: #{DateTime.now.strftime('%Q')}"
          end
          other_component
        end
      end

      register_self_as(:some_component)
    end

    class OtherComponent < Matestack::Ui::Component
      def response
        div id: "static-content-on-other-component" do
          plain "Component 2.1: #{DateTime.now.strftime('%Q')}"
        end
        async rerender_on: "my_event, some_other_event", id: 'async-other-component-1' do
          div id: "dynamic-content-on-other-component" do
            plain "Component 2.2: #{DateTime.now.strftime('%Q')}"
          end
        end
        async rerender_on: "my_other_event", id: 'async-other-component-2' do
          div id: "other-dynamic-content-on-other-component" do
            plain "Component 2.3: #{DateTime.now.strftime('%Q')}"
          end
        end
      end

      register_self_as(:other_component)
    end

    visit "/example"
    static_content_before = page.find("#static-content-on-component").text
    dynamic_content_before = page.find("#dynamic-content-on-component").text
    other_dynamic_content_before = page.find("#other-dynamic-content-on-component").text
    static_content_before_on_other_component = page.find("#static-content-on-other-component").text
    dynamic_content_before_on_other_component = page.find("#dynamic-content-on-other-component").text
    other_dynamic_content_before_on_other_component = page.find("#other-dynamic-content-on-other-component").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).to have_content(static_content_before)
    expect(page).not_to have_content(dynamic_content_before)
    expect(page).to have_content(other_dynamic_content_before)
    expect(page).to have_content(static_content_before_on_other_component)
    expect(page).not_to have_content(dynamic_content_before_on_other_component)
    expect(page).to have_content(other_dynamic_content_before_on_other_component)
    static_content_before = page.find("#static-content-on-component").text
    dynamic_content_before = page.find("#dynamic-content-on-component").text
    other_dynamic_content_before = page.find("#other-dynamic-content-on-component").text
    static_content_before_on_other_component = page.find("#static-content-on-other-component").text
    dynamic_content_before_on_other_component = page.find("#dynamic-content-on-other-component").text
    other_dynamic_content_before_on_other_component = page.find("#other-dynamic-content-on-other-component").text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("some_other_event")')
    expect(page).to have_content(static_content_before)
    expect(page).to have_content(dynamic_content_before)
    expect(page).not_to have_content(other_dynamic_content_before)
    expect(page).not_to have_content(static_content_before_on_other_component)
    expect(page).not_to have_content(dynamic_content_before_on_other_component)
    expect(page).not_to have_content(other_dynamic_content_before_on_other_component)
  end

  it "rerender on event on page-level if wrapped in app" do
    module Example
    end

    class Example::App < Matestack::Ui::App
      def response
        html do
          head do
            unescape csrf_meta_tags
            unescape javascript_pack_tag('application')
          end
          body do
            matestack do
              h1 "My Example App Layout"
              main do
                yield
              end
            end
          end
        end
      end
    end

    module Example::Pages 
    end

    class Example::Pages::ExamplePage < Matestack::Ui::Page
      def response
        async rerender_on: "my_event", id: 'async-example-page' do
          div id: "my-div" do
            plain "#{DateTime.now.strftime('%Q')}"
          end
        end
      end
    end

    class AsyncInAppPagesController < ExampleController
      include Matestack::Ui::Core::Helper

      def example
        render Example::Pages::ExamplePage, matestack_app: Example::App
      end
    end

    Rails.application.routes.append do
      scope "async_rerender_spec" do
        get 'async_specs/in_app/example', to: 'async_in_app_pages#example', as: 'asyn_in_app_example'
      end
    end
    Rails.application.reload_routes!

    visit "async_rerender_spec/async_specs/in_app/example"
    element = page.find("#my-div")
    before_content = element.text

    page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
    expect(page).not_to have_content(before_content)
    element = page.find("#my-div")
    after_content = element.text
    expect(before_content).not_to eq(after_content)
  end

  describe 'iterations' do

    it "rerender async components seperatly" do
      class ExamplePage < Matestack::Ui::Page
        def response
          (0..5).each do |item|
            async rerender_on: "my_event_#{item}, multi_event", id: "async-item-#{item}" do
              div id: "my-div-#{item}" do
                plain "#{item} - #{DateTime.now.strftime('%Q')}"
              end
            end
          end
        end
      end
  
      visit "/example"
      (0..5).each do |item| 
        expect(page).to have_content("#{item} -", count: 1)
      end
      initial_content = (0..5).map { |item| page.find("#my-div-#{item}").text }
  
      # rerender first list element asynchronously, others should not change
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event_0")')
      expect(page).not_to have_content(initial_content[0])
      initial_content[0] = page.find("#my-div-0").text
      (0..5).each do |item| 
        expect(page).to have_content("#{item} -", count: 1)
      end
      (1..5).each do |item| 
        expect(page).to have_content(initial_content[item])
      end
  
      # rerender all elements asynchronously, all should change
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event")')
      (0..5).each do |item| 
        expect(page).to have_content("#{item} -", count: 1)
      end
      (0..5).each do |item| 
        expect(page).not_to have_content(initial_content[item])
      end
    end

    it "return 404 if async component not found and emit event" do
      class ExamplePage < Matestack::Ui::Page
        class_attribute :items
        def response
          items.each do |item|
            async rerender_on: "my_event_#{item}, multi_event", id: "async-item-#{item}" do
              div id: "my-div-#{item}" do
                plain "#{item} - #{DateTime.now.strftime('%Q')}"
              end
            end
          end
          toggle show_on: 'async_rerender_error', id: 'async_error' do
            plain 'Error - {{ event.data.id }}'
          end
        end
      end
  
      ExamplePage.items = (0..5)
      visit "/example"
      (0..5).each do |item| 
        expect(page).to have_content("#{item} -", count: 1)
      end
      initial_content = (0..5).map { |item| page.find("#my-div-#{item}").text }
      expect(page).not_to have_content('Error - async-item-4')
      
      # rerender all elements asynchronously, item 4 should not be changed and
      # a 404 and emit failure event with correct id should be generated
      ExamplePage.items = (0..5).reject { |item| item == 4 }
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("multi_event")')
      ExamplePage.items.each do |item| 
        expect(page).to have_content("#{item} -", count: 1)
      end
      ExamplePage.items.each do |item| 
        expect(page).not_to have_content(initial_content[item])
      end
      expect(page).to have_content(initial_content[4])
      expect(page).to have_content('Error - async-item-4')
    end

  end

  describe 'conditional structures' do

    it "return 404 if async component not found and emit event" do
      class ExamplePage < Matestack::Ui::Page
        class_attribute :active
        def response
          if active
            async rerender_on: "my_event", id: "async-item" do
              div id: "my-div" do
                plain "#{DateTime.now.strftime('%Q')}"
              end
            end
          end
          toggle show_on: 'async_rerender_error', id: 'async_error' do
            plain 'Error - {{ event.data.id }}'
          end
        end
      end
  
      ExamplePage.active = true
      visit "/example"
      initial_content = page.find("#my-div").text
      expect(page).not_to have_content('Error - async-item')
      
      # rerender asynchronously, should return 404 and emit failure event with correct id, content of async should not be changed
      ExamplePage.active = false
      page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event")')
      expect(page).to have_selector('#my-div')
      expect(page).to have_content(initial_content)
      expect(page).to have_content('Error - async-item')
    end

  end

end
