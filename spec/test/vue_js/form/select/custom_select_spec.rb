require 'rails_vue_js_spec_helper'
require_relative "../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do


  before :all do
    Rails.application.routes.append do
      scope "form_custom_select_spec" do
        post '/select_success_form_test', to: 'form_test#success_submit', as: 'custom_select_success_form_test'
        post '/select_failure_form_test/:id', to: 'form_test#failure_submit', as: 'custom_select_failure_form_test'
        post '/select_model_form_test', to: 'model_form_test#model_submit', as: 'custom_select_model_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)

    class Components::CustomFormSelectTest < Matestack::Ui::VueJs::Components::Form::Select

      vue_name "custom-form-select-test"

      def response
        div class: "custom-input-markup" do
          label text: "my form input"
          select select_attributes do
            render_options
          end
          button "change value", "@click": "vc.changeValueViaJs(2)", type: :button
          render_errors
        end
      end

      register_self_as(:custom_form_select_test)
    end
  end

  describe "custom select components" do

    it "can be used for individual radio markup rendering and data processing via custom JS/3rd party JS" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_select_test key: :bar, id: "bar", options: { "Option 1": 1, "Option 2": 2 }
            button 'Submit me!'
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_select_success_form_test_path
          }
        end
      end

      visit '/example'

      expect(page).to have_xpath('//div[@class="custom-input-markup"]/select[@id="bar" and @class="js-added-class"]')

      click_button "change value"

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: 2 }))

      click_button "Submit me!"

    end

    it "can be used within core form along other core inputs" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_select key: :foo, id: "foo", options: { "Option 1": 1, "Option 2": 2 }
            custom_form_select_test key: :bar, id: "bar", options: { "Option 3": 3, "Option 4": 4 }
            button 'Submit me!'
          end
          toggle show_on: "form_submitted", id: 'async-form' do
            plain "form submitted!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_select_success_form_test_path,
            success: { emit: "form_submitted" }
          }
        end
      end

      visit '/example'

      select "Option 2"
      select "Option 4"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: 4, foo: 2 }))

      click_button "Submit me!"
      expect(page).to have_content("form submitted!")
    end

    it "can display server errors async" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_select_test id: "foo", key: :foo, options: { "Option 1": 1, "Option 2": 2 }
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_select_failure_form_test_path(id: 42)
          }
        end
      end

      visit "/example"

      click_button "Submit me!"
      expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
    end

    it "takes an array of options or hash and submits selected item" do
      class ExamplePage < Matestack::Ui::Page

        def response
          matestack_form form_config, :include do
            custom_form_select_test id: "my-array-test-dropdown", key: :array_input, options: ["Array Option 1","Array Option 2"]
            custom_form_select_test id: "my-hash-test-dropdown", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_select_success_form_test_path(42)
          }
        end

      end

      visit "/example"

      select "Array Option 2", from: "my-array-test-dropdown"
      select "Hash Option 2", from: "my-hash-test-dropdown"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: 2 }))
      click_button "Submit me!"
    end

    it "can be initialized with value" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config, :include do
            custom_form_select_test id: "my-array-test-dropdown", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
            custom_form_select_test id: "my-hash-test-dropdown", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }, init: 1
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_select_success_form_test_path(42)
          }
        end
      end

      visit "/example"
      expect(page).to have_field("my-array-test-dropdown", with: "Array Option 1")
      expect(page).to have_field("my-hash-test-dropdown", with: 1)
      select "Array Option 2", from: "my-array-test-dropdown"
      select "Hash Option 2", from: "my-hash-test-dropdown"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: 2 }))
      click_button "Submit me!"
    end

    it "can be mapped to an Active Record Model Array Enum" do
      Object.send(:remove_const, :TestModel)

      class TestModel < ApplicationRecord
        enum status: [ :active, :archived ]
      end

      class ExamplePage < Matestack::Ui::Page
        def prepare
          @test_model = TestModel.new
          @test_model.status = "active"
        end

        def response
          matestack_form form_config, :include do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_select_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_select_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field("status", with: 0)

      fill_in "description", with: value
      select "archived", from: "status"
      click_button "Submit me!"
      expect(page).to have_field("status", with: 0)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to an Active Record Model Hash Enum" do
      Object.send(:remove_const, :TestModel)

      class TestModel < ApplicationRecord
        enum status: { active: 0, archived: 1 }
      end

      class ExamplePage < Matestack::Ui::Page
        def prepare
          @test_model = TestModel.new
          @test_model.status = "active"
        end

        def response
          matestack_form form_config, :include do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_select_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_select_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field("status", with: 0)

      fill_in "description", with: value
      select "archived", from: "status"
      click_button "Submit me!"
      expect(page).to have_field("status", with: 0)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to Active Record Model Errors" do
      Object.send(:remove_const, :TestModel)

      class TestModel < ApplicationRecord
        enum status: { active: 0, archived: 1 }
        validates :status, presence: true
      end

      class ExamplePage < Matestack::Ui::Page
        def prepare
          @test_model = TestModel.new
        end

        def response
          matestack_form form_config, :include do
            # TODO: Provide better Enum Options API
            custom_form_select_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_select_model_form_test_path
          }
        end
      end

      visit "/example"
      expect(page).to have_field("status", with: nil)

      click_button "Submit me!"
      expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"can\'t be blank")]')
    end

    it "can have a class" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config, :include do
            custom_form_select_test id: "my-array-test-dropdown", key: :array_input, options: ["Array Option 1","Array Option 2"], class: "form-control"
            custom_form_select_test id: "my-hash-test-dropdown", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }, class: "form-control"
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_select_success_form_test_path(42),
          }
        end
      end

      visit "/example"
      expect(page).to have_css("#my-array-test-dropdown.form-control")
      expect(page).to have_css("#my-hash-test-dropdown.form-control")
    end
  end

end
