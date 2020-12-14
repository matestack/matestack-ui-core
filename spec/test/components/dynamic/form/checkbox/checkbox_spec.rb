require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  describe "Checkbox" do

    before :all do
      Rails.application.routes.append do
        post '/checkbox_success_form_test/:id', to: 'form_test#success_submit', as: 'checkbox_success_form_test'
        post '/checkbox_success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'checkbox_success_form_test_with_transition'
        post '/checkbox_failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'checkbox_failure_form_test_with_transition'
        post '/checkbox_success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'checkbox_success_form_test_with_redirect'
        post '/checkbox_failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'checkbox_failure_form_test_with_redirect'
        post '/checkbox_failure_form_test/:id', to: 'form_test#failure_submit', as: 'checkbox_failure_form_test'
        post '/checkbox_model_form_test', to: 'model_form_test#model_submit', as: 'checkbox_model_form_test'
      end
      Rails.application.reload_routes!
    end
  
    after :all do
      Object.send(:remove_const, :TestModel)
      load "#{Rails.root}/app/models/test_model.rb"
    end
  
    before :each do
      allow_any_instance_of(FormTestController).to receive(:expect_params)
    end

    it "takes an array of options or hash and submits (multiple) selected item(s)" do
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_checkbox id: "my-array-test-checkbox", key: :array_input, options: ["Array Option 1","Array Option 2"]
            form_checkbox id: "my-hash-test-checkbox", key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }
            form_submit do
              button text: "Submit me!"
            end
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: :checkbox_success_form_test_path,
            params: {
              id: 42
            }
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
            form form_config, :include do
              form_checkbox id: "my-array-test-checkbox", key: :array_input, options: ["Array Option 1","Array Option 2"], init: ["Array Option 1", "Array Option 2"]
              form_checkbox id: "my-hash-test-checkbox", key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }, init: ["2"]
              form_submit do
                button text: "Submit me!"
              end
            end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: :checkbox_success_form_test_path,
            params: {
              id: 42
            }
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
        def prepare
          @test_model = TestModel.new
          @test_model.some_data = ["Array Option 2"]
          @test_model.more_data = ["my_second_key"]
        end

        def response
          form form_config, :include do
            form_checkbox id: "my-array-test-checkbox", key: :some_data, options: TestModel.array_options
            form_checkbox id: "my-hash-test-checkbox", key: :more_data, options: TestModel.hash_options
            form_submit do
              button text: "Submit me!"
            end
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: :checkbox_model_form_test_path
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
      expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"can\'t be blank")]')

      check "Hash Option 2"
      check "Hash Option 1"
      check "Array Option 1"
      click_button "Submit me!"
      expect(page).not_to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"can\'t be blank")]')
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
        def prepare
          @test_model = TestModel.new
        end

        def response
          form form_config, :include do
            form_checkbox id: "my-array-test-checkbox", key: :status, label: 'Status', class: 'test'
            form_submit do
              button text: "Submit me!"
            end
            toggle show_on: 'success', id: 'async-page' do
              plain 'Success'
            end
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: :checkbox_model_form_test_path,
            success: {
              emit: :success
            }
          }
        end
      end

      visit "/example"
      expect(page).to have_field('Status', checked: false)
      expect(page).to have_css('input.test')

      check 'Status'
      click_button "Submit me!"
      expect(page).to have_content('Success')
      expect(TestModel.last.status).to eq(1)
    end

  end

end