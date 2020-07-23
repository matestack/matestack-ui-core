require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      post '/success_form_test/:id', to: 'form_test#success_submit', as: 'success_form_test'
      post '/success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'success_form_test_with_transition'
      post '/failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'failure_form_test_with_transition'
      post '/success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'success_form_test_with_redirect'
      post '/failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'failure_form_test_with_redirect'
      post '/failure_form_test/:id', to: 'form_test#failure_submit', as: 'failure_form_test'
      post '/model_form_test', to: 'model_form_test#model_submit', as: 'model_form_test'
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

  describe "Example 6 - Async submit update request with success, which does not reset the input fields" do
    # https://github.com/matestack/matestack-ui-core/issues/304

    # This example uses the `TestModel` with attributes `title` and `description`
    # defined in `spec/dummy/app/models/test_model.rb`.

    before do
      class TestModelPage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: 'title', key: :title, type: :text
            form_input id: 'description', key: :description, type: :text
            form_submit { button text: "Save" }
          end
          async show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          async show_on: "update_successful", hide_after: 5000, id: 'async-form-successful' do
            plain "Update successful"
          end
        end

        private

        def form_config
          {
            for: @test_model,
            method: :put,
            path: "/some_test_models/#{@test_model.id}",
            success: { emit: "update_successful" },
            failure: { emit: "form_has_errors" }
          }
        end
      end

      class SomeTestModelsController < ApplicationController
        include Matestack::Ui::Core::ApplicationHelper

        def show
          @test_model = TestModel.find params[:id]
          render TestModelPage
        end

        def update
          @test_model = TestModel.find params[:id]
          @test_model.update test_model_params
          if @test_model.errors.any?
            render json: {
              errors: user.errors
            }, status: :unproccessable_entity
          else
            render json: {}, status: :ok
          end
        end

        protected

        def test_model_params
          params.require(:test_model).permit(:title, :description)
        end
      end

      Rails.application.routes.draw do
        resources :some_test_models
      end
    end

    after do
      Rails.application.reload_routes!
    end

    specify do
      test_model = TestModel.create title: "Foo", description: "This is a very nice foo!"
      visit Rails.application.routes.url_helpers.some_test_model_path(test_model)
      expect(find_field(:title).value).to eq "Foo"

      fill_in :title, with: "Bar"
      fill_in :description, with: "This is a equally nice bar!"
      click_on "Save"
      expect(page).to have_text "Update successful"
      expect(find_field(:title).value).to eq "Bar"
      expect(find_field(:description).value).to eq "This is a equally nice bar!"
    end
  end

  describe "Example 6.1 - Async submit with success configured to reset the input fields" do
    # https://github.com/matestack/matestack-ui-core/pull/314#discussion_r362826471

    before do
      class SearchPage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: 'query', key: :query, type: :text
            form_submit { button text: "Search" }
          end
          async show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          async show_on: "submission_successful", hide_after: 5000, id: 'async-form-successful' do
            plain "Submission successful"
          end
        end

        private

        def form_config
          {
            for: :search,
            method: :get,
            path: "#",
            success: { emit: "submission_successful", reset: true },
            failure: { emit: "form_has_errors" }
          }
        end
      end

      class SearchesController < ApplicationController
        include Matestack::Ui::Core::ApplicationHelper

        def index
          render SearchPage
        end
      end

      Rails.application.routes.draw do
        get 'search', to: 'searches#index'
      end
    end

    after do
      Rails.application.reload_routes!
    end

    specify do
      visit "/search"
      expect(find_field(:query).value).to eq ""

      fill_in :query, with: "Bar"
      click_on "Search"
      expect(page).to have_text "Submission successful"
      expect(find_field(:query).value).to eq ""
    end
  end

  describe "Example 6.2 - Async submit with success configured not to reset the input fields" do
    # https://github.com/matestack/matestack-ui-core/pull/314#discussion_r362826471

    before do
      class SearchPage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: 'query', key: :query, type: :text
            form_submit { button text: "Search" }
          end
          async show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          async show_on: "submission_successful", hide_after: 5000, id: 'async-form-successful' do
            plain "Submission successful"
          end
        end

        private

        def form_config
          {
            for: :search,
            method: :get,
            path: "#",
            success: { emit: "submission_successful", reset: false },
            failure: { emit: "form_has_errors" }
          }
        end
      end

      class SearchesController < ApplicationController
        include Matestack::Ui::Core::ApplicationHelper

        def index
          render SearchPage
        end
      end

      Rails.application.routes.draw do
        get 'search', to: 'searches#index'
      end
    end

    after do
      Rails.application.reload_routes!
    end

    specify do
      visit "/search"
      expect(find_field(:query).value).to eq ""

      fill_in :query, with: "Bar"
      click_on "Search"
      expect(page).to have_text "Submission successful"
      expect(find_field(:query).value).to eq "Bar"
    end
  end



  describe "Form Select Component" do

    describe "Dropdown" do

      it "takes an array of options or hash and submits selected item" do
        class ExamplePage < Matestack::Ui::Page

          def response
            form form_config, :include do
              form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"]
              form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end

        end

        visit "/example"
        select "Array Option 2", from: "my-array-test-dropdown"
        select "Hash Option 2", from: "my-hash-test-dropdown"
        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "2" }))
        click_button "Submit me!"
      end

      it "can be initialized with value" do
        class ExamplePage < Matestack::Ui::Page
          def response
            form form_config, :include do
              form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
              form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: "1"
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end
        end

        visit "/example"
        expect(page).to have_field("my-array-test-dropdown", with: "Array Option 1")
        expect(page).to have_field("my-hash-test-dropdown", with: "1")
        select "Array Option 2", from: "my-array-test-dropdown"
        select "Hash Option 2", from: "my-hash-test-dropdown"
        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "2" }))
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
            }
          end
        end

        visit "/example"
        expect(page).to have_field("status", with: nil)

        click_button "Submit me!"
        expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"can\'t be blank")]')
      end

      it "can have a label"

      it "can have a placeholder"

      it "can have a class" do
        class ExamplePage < Matestack::Ui::Page
          def response
            form form_config, :include do
              form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"], class: "form-control"
              form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, class: "form-control"
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end
        end

        visit "/example"
        expect(page).to have_css("#my-array-test-dropdown.form-control")
        expect(page).to have_css("#my-hash-test-dropdown.form-control")
      end
    end

    describe "Checkbox" do

      it "takes an array of options or hash and submits (multiple) selected item(s)" do
        class ExamplePage < Matestack::Ui::Page
          def response
            form form_config, :include do
              form_select id: "my-array-test-checkbox", key: :array_input, type: :checkbox, options: ["Array Option 1","Array Option 2"]
              form_select id: "my-hash-test-checkbox", key: :hash_input, type: :checkbox, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
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
                form_select id: "my-array-test-checkbox", key: :array_input, type: :checkbox, options: ["Array Option 1","Array Option 2"], init: ["Array Option 1", "Array Option 2"]
                form_select id: "my-hash-test-checkbox", key: :hash_input, type: :checkbox, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: ["2"]
                form_submit do
                  button text: "Submit me!"
                end
              end
          end

          def form_config
            {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
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
            { "my_first_key": "Hash Option 1", "my_second_key": "Hash Option 2" }
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
              form_select id: "my-array-test-checkbox", key: :some_data, type: :checkbox, options: TestModel.array_options
              form_select id: "my-hash-test-checkbox", key: :more_data, type: :checkbox, options: TestModel.hash_options
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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

      it "can have a label"

    end

    describe "Radio Button" do

      it "takes an array of options or hash and submits one selected item" do
        class ExamplePage < Matestack::Ui::Page
          def response
            form form_config, :include do
              form_select id: "my-array-test-radio", key: :array_input, type: :radio, options: ["Array Option 1","Array Option 2"]
              form_select id: "my-hash-test-radio", key: :hash_input, type: :radio, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end
        end

        visit "/example"
        choose('Array Option 2')
        choose('Hash Option 1')
        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "1" }))
        click_button "Submit me!"
      end

      it "can be initialized by (multiple) item(s)" do
        class ExamplePage < Matestack::Ui::Page
          def response
            form form_config, :include do
              form_select id: "my-array-test-radio", key: :array_input, type: :radio, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
              form_select id: "my-hash-test-radio", key: :hash_input, type: :radio, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: "2"
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end
        end

        visit "/example"
        expect(page).to have_field('Array Option 1', checked: true)
        expect(page).to have_field('Array Option 2', checked: false)
        expect(page).to have_field('Hash Option 1', checked: false)
        expect(page).to have_field('Hash Option 2', checked: true)
        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 1", hash_input: "2" }))
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: @test_model,
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: 'test_model',
              method: :post,
              path: :model_form_test_path
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
            form form_config, :include do
              form_input id: "description", key: :description, type: :text
              # TODO: Provide better Enum Options API
              form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: :test_model,
              method: :post,
              path: :model_form_test_path
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

    describe "Usage on Component Level" do

      it "Example 1 - Async submit request with clientside payload from component-level" do
        module Components end

        class Components::SomeComponent < Matestack::Ui::StaticComponent
          def response
            form form_config, :include do
              form_input id: "my-test-input", key: :foo, type: :text
              form_submit do
                button text: "Submit me!"
              end
            end
          end

          def form_config
            return {
              for: :my_object,
              method: :post,
              path: :success_form_test_path,
              params: {
                id: 42
              }
            }
          end

          register_self_as(:custom_some_component)
        end

        class ExamplePage < Matestack::Ui::Page
          def response
            div do
              custom_some_component
            end
          end
        end

        visit "/example"
        fill_in "my-test-input", with: "bar"
        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { foo: "bar" }))
        click_button "Submit me!"
      end
    end

  end

  it "range input can be initialized with min, max, step and value" do
    class ExamplePage < Matestack::Ui::Page
      def response
        form form_config, :include do
          form_input id: "range-input",
            key: :range_input, type: :range,
            init: 3, min: 0, max: 10, step: 1, list: "my_list"
          form_submit do
            button text: "Submit me!"
          end
        end
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :success_form_test_path,
          params: {
            id: 42
          }
        }
      end
    end

    visit "/example"
    expect(page).to have_field("range-input", with: "3")
    expect(page).to have_selector('#range-input[min="0"][max="10"][step="1"][list="my_list"]')
  end

end
