require 'rails_vue_js_spec_helper'
require_relative "../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do


  before :all do
    Rails.application.routes.append do
      scope "form_custom_checkbox_spec" do
        post '/checkbox_success_form_test', to: 'form_test#success_submit', as: 'custom_checkbox_success_form_test'
        post '/checkbox_failure_form_test/:id', to: 'form_test#failure_submit', as: 'custom_checkbox_failure_form_test'
        post '/checkbox_model_form_test', to: 'model_form_test#model_submit', as: 'custom_checkbox_model_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)

    class Components::CustomFormCheckboxTest < Matestack::Ui::VueJs::Components::Form::Checkbox
      vue_name "custom-form-checkbox-test"

      def response
        div class: "custom-input-markup" do
          label "my form input"
          render_options
          button "change value", "@click": "vc.changeValueViaJs(2)", type: :button
          render_errors
        end
      end

      register_self_as(:custom_form_checkbox_test)
    end
  end

  describe "custom checkbox components" do

    it "can be used for individual radio markup rendering and data processing via custom JS/3rd party JS" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_checkbox_test key: :bar, id: "bar", options: { "Option 1": 1, "Option 2": 2 }
            button 'Submit me!'
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_checkbox_success_form_test_path
          }
        end
      end

      visit '/example'
      expect(page).to have_xpath('//div[@class="custom-input-markup"]/input[@id="bar_1" and @class="js-added-class"]')
      click_button "change value"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: 2 }))
      click_button "Submit me!"
    end

    it "can be used within core form along other core inputs" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_checkbox key: :foo, id: "foo", options: { "Option 1": 1, "Option 2": 2 }
            custom_form_checkbox_test key: :bar, id: "bar", options: { "Option 3": 3, "Option 4": 4 }
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
            path: custom_checkbox_success_form_test_path,
            success: { emit: "form_submitted" }
          }
        end
      end

      visit '/example'

      check "Option 2"
      check "Option 4"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: ["4"], foo: ["2"] }))

      click_button "Submit me!"
      expect(page).to have_content("form submitted!")
    end

    it "can display server errors async" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_checkbox_test id: "foo", key: :foo, type: :text
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_checkbox_failure_form_test_path(id: 42)
          }
        end
      end

      visit "/example"

      click_button "Submit me!"
      expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
    end

    it "takes an array of options or hash and submits (multiple) selected item(s)" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_checkbox_test id: "my-array-test-checkbox", key: :array_input, options: ["Array Option 1","Array Option 2"]
            custom_form_checkbox_test id: "my-hash-test-checkbox", key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_checkbox_success_form_test_path
          }
        end

      end

      visit "/example"
      check "Array Option 2"
      check "Hash Option 1"
      check "Hash Option 2"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: ["Array Option 2"], hash_input: ["1", "2"] }))
      click_button "Submit me!"
    end

    it "can be initialized by (multiple) item(s)" do
      class ExamplePage < Matestack::Ui::Page
        def response
            matestack_form form_config do
              custom_form_checkbox_test id: "my-array-test-checkbox", key: :array_input, options: ["Array Option 1","Array Option 2"], init: ["Array Option 1", "Array Option 2"]
              custom_form_checkbox_test id: "my-hash-test-checkbox", key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }, init: ["2"]
              button "Submit me!"
            end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_checkbox_success_form_test_path
          }
        end
      end

      visit "/example"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: ["Array Option 1", "Array Option 2"], hash_input: ["2"] }))
      click_button "Submit me!"
    end

    it "can be mapped to Active Record Model Column, which is serialized as an Array" do
      Object.send(:remove_const, :TestModel)

      class TestModel < ApplicationRecord
        serialize :some_data, Array
        serialize :more_data, Array
        validates :more_data, presence: true

        def self.array_options
          ["Array Option 1","Array Option 2"]
        end

        def self.hash_options
          { "Hash Option 1": "my_first_key", "Hash Option 2": "my_second_key" }
        end
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.new
          @test_model.some_data = ["Array Option 2"]
          @test_model.more_data = ["my_second_key"]
          matestack_form form_config do
            custom_form_checkbox_test id: "my-array-test-checkbox", key: :some_data, options: TestModel.array_options
            custom_form_checkbox_test id: "my-hash-test-checkbox", key: :more_data, options: TestModel.hash_options
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_checkbox_model_form_test_path
          }
        end
      end

      visit "/example"
      expect(page).to have_field('Array Option 1', checked: false)
      expect(page).to have_field('Array Option 2', checked: true)
      expect(page).to have_field('Hash Option 1', checked: false)
      expect(page).to have_field('Hash Option 2', checked: true)

      uncheck "Hash Option 2"
      click_button "Submit me!"
      expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"can\'t be blank")]')

      check "Hash Option 2"
      check "Hash Option 1"
      check "Array Option 1"
      click_button "Submit me!"
      expect(page).not_to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"can\'t be blank")]')
      #form should now be reset
      expect(page).to have_field('Array Option 1', checked: false)
      expect(page).to have_field('Array Option 2', checked: true)
      expect(page).to have_field('Hash Option 1', checked: false)
      expect(page).to have_field('Hash Option 2', checked: true)
      expect(TestModel.last.some_data).to eq(["Array Option 2","Array Option 1"])
      expect(TestModel.last.more_data).to eq(["my_second_key", "my_first_key"])
    end

    it 'can work as a simple true false checkbox' do
      Object.send(:remove_const, :TestModel)
      load "#{Rails.root}/app/models/test_model.rb"

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.new
          matestack_form form_config do
            custom_form_checkbox_test id: "my-array-test-checkbox", key: :status, label: 'Status'
            button "Submit me!"
            toggle show_on: 'success', id: 'async-page' do
              plain 'Success'
            end
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_checkbox_model_form_test_path,
            success: {
              emit: :success
            }
          }
        end
      end

      visit "/example"
      expect(page).to have_field('Status', checked: false)

      check 'Status'
      click_button "Submit me!"
      expect(page).to have_content('Success')
      expect(TestModel.last.status).to eq(1)
    end

  end

end
