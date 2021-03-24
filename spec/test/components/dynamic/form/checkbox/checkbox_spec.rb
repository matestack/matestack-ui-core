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
          matestack_form form_config do
            form_checkbox key: :array_input, options: ["Array Option 1","Array Option 2"]
            form_checkbox key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: checkbox_success_form_test_path(id: 42),
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

    it "renders auto generated IDs based on user specified ID and optional user specified class per checkbox" do
      class ExamplePage < Matestack::Ui::Page
        def response
            matestack_form form_config do
              form_checkbox id: "foo", key: :foo, options: [1, 2]
              form_checkbox id: "bar", key: :bar, options: [1, 2], class: "some-class"
              button "Submit me!"
            end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: checkbox_success_form_test_path(id: 42),
          }
        end
      end

      visit "/example"
      expect(page).to have_selector('#foo_1')
      expect(page).to have_selector('#foo_2')
      expect(page).to have_selector('.some-class#bar_1')
      expect(page).to have_selector('.some-class#bar_2')
    end

    it "can be initialized by (multiple) item(s)" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_checkbox id: "my-array-test-checkbox", key: :array_input, options: ["Array Option 1","Array Option 2"], init: ["Array Option 1", "Array Option 2"]
            form_checkbox id: "my-hash-test-checkbox", key: :hash_input, options: { "Hash Option 1": "1", "Hash Option 2": "2" }, init: ["2"]
            button "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: checkbox_success_form_test_path(id: 42),
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
            form_checkbox id: "my-array-test-checkbox", key: :some_data, options: TestModel.array_options
            form_checkbox id: "my-hash-test-checkbox", key: :more_data, options: TestModel.hash_options
            button "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: checkbox_model_form_test_path
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
            form_checkbox id: "my-array-test-checkbox", key: :status, label: 'Status'
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
            path: checkbox_model_form_test_path,
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

    it "can be initialized with a boolean/integer value as true" do
      Object.send(:remove_const, :TestModel)
      load "#{Rails.root}/app/models/test_model.rb"

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.new
          @test_model.status = 1
          @test_model.some_boolean_value = true
          matestack_form form_config do
            form_checkbox id: "init-as-integer-from-model", key: :status, label: 'Integer Value from Model'
            form_checkbox id: "init-as-boolean-from-model", key: :some_boolean_value, label: 'Boolean Value from Model'
            form_checkbox id: "init-as-integer-from-config", key: :foo, label: 'Integer Value from Config', init: 1
            form_checkbox id: "init-as-boolean-from-config", key: :bar, label: 'Boolean Value from Config', init: true
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
            path: checkbox_success_form_test_path(id: 42),
            success: {
              emit: :success
            }
          }
        end
      end

      visit "/example"

      expect(page).to have_field('Integer Value from Model', checked: true)
      expect(page).to have_field('Boolean Value from Model', checked: true)
      expect(page).to have_field('Integer Value from Config', checked: true)
      expect(page).to have_field('Boolean Value from Config', checked: true)

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(test_model: { status: true, some_boolean_value: true, foo: true, bar: true }))
      click_button "Submit me!"

    end

    it "can be initialized with a boolean/integer value as false" do
      Object.send(:remove_const, :TestModel)
      load "#{Rails.root}/app/models/test_model.rb"

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.new
          @test_model.status = 0
          @test_model.some_boolean_value = false
          matestack_form form_config do
            form_checkbox id: "init-as-integer-from-model", key: :status, label: 'Integer Value from Model'
            form_checkbox id: "init-as-boolean-from-model", key: :some_boolean_value, label: 'Boolean Value from Model'
            form_checkbox id: "init-as-integer-from-config", key: :foo, label: 'Integer Value from Config', init: 0
            form_checkbox id: "init-as-boolean-from-config", key: :bar, label: 'Boolean Value from Config', init: false
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
            path: checkbox_success_form_test_path(id: 42),
            success: {
              emit: :success
            }
          }
        end
      end

      visit "/example"

      expect(page).to have_field('Integer Value from Model', checked: false)
      expect(page).to have_field('Boolean Value from Model', checked: false)
      expect(page).to have_field('Integer Value from Config', checked: false)
      expect(page).to have_field('Boolean Value from Config', checked: false)
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(test_model: { status: false, some_boolean_value: false, foo: false, bar: false }))
      click_button "Submit me!"

    end

    it "can be initialized with a boolean/integer value as null" do
      Object.send(:remove_const, :TestModel)
      load "#{Rails.root}/app/models/test_model.rb"

      class ExamplePage < Matestack::Ui::Page
        def response
          @test_model = TestModel.new
          matestack_form form_config do
            form_checkbox id: "init-as-integer-from-model", key: :status, label: 'Integer Value from Model'
            form_checkbox id: "init-as-boolean-from-model", key: :some_boolean_value, label: 'Boolean Value from Model'
            form_checkbox id: "init-as-integer-from-config", key: :foo, label: 'Integer Value from Config' #, init: 0
            form_checkbox id: "init-as-boolean-from-config", key: :bar, label: 'Boolean Value from Config' #, init: false
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
            path: checkbox_success_form_test_path(id: 42),
            success: {
              emit: :success
            }
          }
        end
      end

      visit "/example"

      expect(page).to have_field('Integer Value from Model', checked: false)
      expect(page).to have_field('Boolean Value from Model', checked: false)
      expect(page).to have_field('Integer Value from Config', checked: false)
      expect(page).to have_field('Boolean Value from Config', checked: false)

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(test_model: { status: nil, some_boolean_value: nil, foo: nil, bar: nil }))
      click_button "Submit me!"

    end

  end

end
