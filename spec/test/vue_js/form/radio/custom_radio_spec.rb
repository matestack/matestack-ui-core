require 'rails_vue_js_spec_helper'
require_relative "../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do


  before :all do
    Rails.application.routes.append do
      scope "form_custom_radio_spec" do
        post '/radio_success_form_test', to: 'form_test#success_submit', as: 'custom_radio_success_form_test'
        post '/radio_failure_form_test/:id', to: 'form_test#failure_submit', as: 'custom_radio_failure_form_test'
        post '/radio_model_form_test', to: 'model_form_test#model_submit', as: 'custom_radio_model_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)

    class Components::CustomFormRadioTest < Matestack::Ui::VueJs::Components::Form::Radio
      vue_name "custom-form-radio-test"

      def response
        div class: "custom-input-markup" do
          label text: "my form input"
          render_options
          button "change value", "@click": "vc.changeValueViaJs(2)", type: :button
          render_errors
        end
      end

      register_self_as(:custom_form_radio_test)
    end
  end

  describe "custom radio components" do

    it "can be used for individual radio markup rendering and data processing via custom JS/3rd party JS" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_radio_test key: :bar, id: "bar", options: { "Option 1": 1, "Option 2": 2 }
            button text: 'Submit me!'
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_radio_success_form_test_path
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
            form_radio key: :foo, id: "foo", options: { "Option 1": 1, "Option 2": 2 }
            custom_form_radio_test key: :bar, id: "bar", options: { "Option 3": 3, "Option 4": 4 }
            button text: 'Submit me!'
          end
          toggle show_on: "form_submitted", id: 'async-form' do
            plain "form submitted!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_radio_success_form_test_path,
            success: { emit: "form_submitted" }
          }
        end
      end

      visit '/example'

      choose "Option 2"
      choose "Option 4"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: 4, foo: 2 }))

      click_button "Submit me!"
      expect(page).to have_content("form submitted!")
    end

    it "can display server errors async" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_radio_test id: "foo", key: :foo, type: :text
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_radio_failure_form_test_path(id: 42)
          }
        end
      end

      visit "/example"

      click_button "Submit me!"
      expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
    end

    it "takes an array of options or hash and submits one selected item" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_radio_test id: "my-array-test-radio", key: :array_input, options: ["Array Option 1","Array Option 2"]
            custom_form_radio_test id: "my-hash-test-radio", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: custom_radio_success_form_test_path
          }
        end
      end

      visit "/example"

      choose('Array Option 2')
      choose('Hash Option 1')
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: 1 }))
      click_button "Submit me!"
    end

    it "can be initialized by (multiple) item(s)" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_radio_test id: "my-array-test-radio", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
            custom_form_radio_test id: "my-hash-test-radio", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }, init: 2
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_radio_success_form_test_path
          }
        end
      end

      visit "/example"
      expect(page).to have_field('Array Option 1', checked: true)
      expect(page).to have_field('Array Option 2', checked: false)
      expect(page).to have_field('Hash Option 1', checked: false)
      expect(page).to have_field('Hash Option 2', checked: true)
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: "Array Option 1", hash_input: 2 }))
      click_button "Submit me!"
    end

    it "can extend initialization via custom JS (trigger 3rd party libraries for example)" do

      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            custom_form_radio_test id: "my-array-test-radio", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "change me via JS"
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: custom_radio_success_form_test_path
          }
        end
      end

      visit "/example"

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { array_input: "Array Option 1" }))
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
          matestack_form form_config do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_radio_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: @test_model,
            method: :post,
            path: custom_radio_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field('active', checked: true)

      fill_in "description", with: value
      choose('archived')
      click_button "Submit me!"
      expect(page).to have_field('active', checked: true)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to an Active Record Model Hash Enum" do
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
          matestack_form form_config do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_radio_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: @test_model,
            method: :post,
            path: custom_radio_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field('active', checked: true)

      fill_in "description", with: value
      choose('archived')
      click_button "Submit me!"
      expect(page).to have_field('active', checked: true)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to Active Record Model Errors" do
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
          matestack_form form_config do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_radio_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: custom_radio_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field('active', checked: true)

      fill_in "description", with: value
      choose('archived')
      click_button "Submit me!"
      expect(page).to have_field('active', checked: true)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to Active Record Model Errors - string options[:for] version" do
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
          matestack_form form_config do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_radio_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: 'test_model',
            method: :post,
            path: custom_radio_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field('active', checked: true)
      fill_in "description", with: value
      choose('archived')
      click_button "Submit me!"
      expect(page).to have_field('active', checked: true)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

    it "can be mapped to Active Record Model Errors - symbol options[:for] version" do
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
          matestack_form form_config do
            form_input id: "description", key: :description, type: :text
            # TODO: Provide better Enum Options API
            custom_form_radio_test id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: :test_model,
            method: :post,
            path: custom_radio_model_form_test_path
          }
        end
      end

      visit "/example"
      value = "#{DateTime.now}"
      expect(page).to have_field('active', checked: true)
      fill_in "description", with: value
      choose('archived')
      click_button "Submit me!"
      expect(page).to have_field('active', checked: true)
      expect(page).to have_field("description", with: "")
      expect(TestModel.last.description).to eq(value)
      expect(TestModel.last.status).to eq("archived")
    end

  end

end
