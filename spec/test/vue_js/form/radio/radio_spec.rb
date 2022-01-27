require 'rails_vue_js_spec_helper'
require_relative "../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do

  describe "Radio" do

    before :all do
      Rails.application.routes.append do
        post '/radio_success_form_test/:id', to: 'form_test#success_submit', as: 'radio_success_form_test'
        post '/radio_success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'radio_success_form_test_with_transition'
        post '/radio_failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'radio_failure_form_test_with_transition'
        post '/radio_success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'radio_success_form_test_with_redirect'
        post '/radio_failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'radio_failure_form_test_with_redirect'
        post '/radio_failure_form_test/:id', to: 'form_test#failure_submit', as: 'radio_failure_form_test'
        post '/radio_model_form_test', to: 'model_form_test#model_submit', as: 'radio_model_form_test'
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

    it "renders auto generated IDs based on user specified ID and optional user specified class per radio button" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_radio id: "foo", key: :foo, options: [1, 2]
            form_radio id: "bar", key: :bar, options: [1, 2], class: "some-class"
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: radio_success_form_test_path(id: 42),
          }
        end
      end

      visit "/example"
      expect(page).to have_selector('#foo_1')
      expect(page).to have_selector('#foo_2')
      expect(page).to have_selector('.some-class#bar_1')
      expect(page).to have_selector('.some-class#bar_2')
    end

    it "takes an array of options or hash and submits one selected item" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_radio id: "my-array-test-radio", key: :array_input, options: ["Array Option 1","Array Option 2"]
            form_radio id: "my-hash-test-radio", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: radio_success_form_test_path(id: 42),
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
            form_radio id: "my-array-test-radio", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
            form_radio id: "my-hash-test-radio", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }, init: 2
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: radio_success_form_test_path(id: 42),
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
            form_radio id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: @test_model,
            method: :post,
            path: radio_model_form_test_path
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
            form_radio id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          {
            for: @test_model,
            method: :post,
            path: radio_model_form_test_path
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
            form_radio id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: @test_model,
            method: :post,
            path: radio_model_form_test_path
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
            form_radio id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: 'test_model',
            method: :post,
            path: radio_model_form_test_path
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
            form_radio id: "status", key: :status, options: TestModel.statuses, init: TestModel.statuses[@test_model.status]
            button text: "Submit me!"
          end
        end

        def form_config
          return {
            for: :test_model,
            method: :post,
            path: radio_model_form_test_path
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

    it "can have a label"

  end
end
