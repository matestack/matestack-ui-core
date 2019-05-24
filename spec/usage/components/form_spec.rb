require_relative "../../support/utils"
include Utils

class TestController < ActionController::Base

  before_action :check_params

  def check_params
    expect_params(params.permit!.to_h)
  end

  def expect_params(params)
  end

end

describe "Form Component", type: :feature, js: true do

  before :all do

    class FormTestController < TestController

      def success_submit
        render json: { message: "server says: form submitted successfully" }, status: 200
      end

      def failure_submit
        render json: {
          message: "server says: form had errors",
          errors: { foo: ["seems to be invalid"] }
        }, status: 400
      end

    end

    Rails.application.routes.append do
      post '/success_form_test/:id', to: 'form_test#success_submit', as: 'success_form_test'
      post '/failure_form_test/:id', to: 'form_test#failure_submit', as: 'failure_form_test'
    end
    Rails.application.reload_routes!

    class ModelFormTestController < TestController

      def model_submit
        @test_model = TestModel.create(model_params)
        if @test_model.errors.any?
          render json: {
            message: "server says: something went wrong!",
            errors: @test_model.errors
          }, status: :unproccessable_entity
        else
          render json: {
            message: "server says: form submitted successfully!"
          }, status: :ok
        end
      end

      protected

      def model_params
        params.require(:test_model).permit(:title, :description, :status, some_data: [], more_data: [])
      end

    end

    Rails.application.routes.append do
      post '/model_form_test', to: 'model_form_test#model_submit', as: 'model_form_test'
    end
    Rails.application.reload_routes!

  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  it "Example 1 - Async submit request with clientside payload" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "my-test-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    fill_in "my-test-input", with: "bar"
    click_button "Submit me!"

    expect_any_instance_of(FormTestController).to receive(:expect_params)
      .with(hash_including(my_object: { foo: "bar" }))

  end

  it "Example 2 - Async submit request and clears inputs on success" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "my-test-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    fill_in "my-test-input", with: "bar"

    expect(find_field("my-test-input").value).to eq "bar"

    click_button "Submit me!"

    expect(find_field("my-test-input").value).to eq ""

  end

  it "Example 2 - Async submit request with success event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "my-test-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
          async show_on: "my_form_success" do
            plain "{{event.data.message}}"
          end
        }
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :success_form_test_path,
          params: {
            id: 42
          },
          success: {
            emit: "my_form_success"
          }
        }
      end

    end

    visit "/example"

    fill_in "my-test-input", with: "bar"
    click_button "Submit me!"

    expect(page).to have_content("server says: form submitted successfully")

  end

  it "Example 3 - Async submit request with failure event" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "my-test-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
          async show_on: "my_form_failure" do
            plain "{{event.data.message}}"
            plain "{{event.data.errors}}"
          end
        }
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :failure_form_test_path,
          params: {
            id: 42
          },
          failure: {
            emit: "my_form_failure"
          }
        }
      end

    end

    visit "/example"

    fill_in "my-test-input", with: "bar"
    click_button "Submit me!"

    expect(page).to have_content("server says: form had errors")
    expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]")

  end

  it "Example 4 - Async submit request with success transition" do
    class Apps::ExampleApp < App::Cell::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          main do
            page_content
          end
          async show_on: "my_form_success", hide_after: 300 do
            plain "{{event.data.message}}"
          end
          async show_on: "my_form_failure", hide_after: 300 do
            plain "{{event.data.message}}"
            plain "{{event.data.errors}}"
          end
        }
      end

    end

    module Pages::ExampleApp

    end

    class Pages::ExampleApp::ExamplePage < Page::Cell::Page

      def response
        components {
          heading size: 2, text: "This is Page 1"
          form form_config, :include do
            form_input id: "my-test-input-on-page-1", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :success_form_test_path,
          params: {
            id: 42
          },
          success: {
            emit: "my_form_success",
            transition: {
              path: :form_test_page_2_path,
              params: {
                id: 42
              }
            }
          }
        }
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Page::Cell::Page

      def response
        components {
          heading size: 2, text: "This is Page 2"
          form form_config, :include do
            form_input id: "my-test-input-on-page-2", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :failure_form_test_path,
          params: {
            id: 42
          },
          failure: {
            emit: "my_form_failure",
            transition: {
              path: :form_test_page_1_path
            }
          }
        }
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        responder_for(Pages::ExampleApp::ExamplePage)
      end

      def page2
        responder_for(Pages::ExampleApp::SecondExamplePage)
      end

    end

    Rails.application.routes.append do
      scope :form_test do
        get 'page1', to: 'example_app_pages#page1', as: 'form_test_page_1'
        get 'page2/:id', to: 'example_app_pages#page2', as: 'form_test_page_2'
      end
    end
    Rails.application.reload_routes!

    visit "form_test/page1"

    expect(page).to have_content("This is Page 1")

    fill_in "my-test-input-on-page-1", with: "bar"
    click_button "Submit me!"

    expect(page).to have_content("server says: form submitted successfully")

    expect(page).to have_content("This is Page 2")

    fill_in "my-test-input-on-page-2", with: "bar"
    click_button "Submit me!"

    expect(page).to have_content("server says: form had errors")
    expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]")

    expect(page).to have_content("This is Page 1")

  end

  describe "Form Input Component" do

    it "Example 1 - Supports 'text', 'password', 'number', 'email', 'textarea' type" do

      class ExamplePage < Page::Cell::Page

        def response
          components {
            form form_config, :include do
              form_input id: "text-input",      key: :text_input, type: :text
              form_input id: "email-input",     key: :email_input, type: :email
              form_input id: "password-input",  key: :password_input, type: :password
              form_input id: "number-input",    key: :number_input, type: :number
              form_input id: "textarea-input",  key: :textarea_input, type: :textarea
              form_submit do
                button text: "Submit me!"
              end
            end
          }
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

      fill_in "text-input", with: "text"
      fill_in "email-input", with: "name@example.com"
      fill_in "password-input", with: "secret"
      fill_in "number-input", with: 123
      fill_in "textarea-input", with: "Hello \n World!"
      click_button "Submit me!"

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(
          my_object: {
            text_input: "text",
            email_input: "name@example.com",
            password_input: "secret",
            number_input: 123,
            textarea_input: "Hello \n World!"
          }
        ))

    end

  end

  it "can be initialized with value" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "text-input", key: :text_input, type: :text, init: "some value"
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    expect(page).to have_field("text-input", with: "some value")

  end

  it "can be prefilled with a placeholder" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "text-input", key: :text_input, type: :text, placeholder: "some placeholder"
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    expect(page).to have_field("text-input", with: "")
    expect(page).to have_field("text-input", placeholder: "some placeholder")

  end

  it "can get a label" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "text-input", key: :text_input, type: :text, label: "some label"
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    expect(page).to have_xpath('//label[contains(.,"some label")]')

  end

  it "can display server errors async" do

    class ExamplePage < Page::Cell::Page

      def response
        components {
          form form_config, :include do
            form_input id: "text-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: :failure_form_test_path,
          params: {
            id: 42
          }
        }
      end

    end

    visit "/example"

    fill_in "text-input", with: "text"
    click_button "Submit me!"

    expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"seems to be invalid")]')

  end

  it "can be mapped to an Active Record Model" do

    class TestModel < ApplicationRecord

      validates :description, presence:true

    end

    class ExamplePage < Page::Cell::Page

      def prepare
        @test_model = TestModel.new
        @test_model.title = "Title"
      end

      def response
        components {
          form form_config, :include do
            form_input id: "title", key: :title, type: :text
            form_input id: "description", key: :description, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        }
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

    expect(page).to have_field("title", with: "Title")
    click_button "Submit me!"
    expect(page).to have_field("title", with: "Title")
    expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"can\'t be blank")]')

    value = "#{DateTime.now}"
    fill_in "description", with: value
    page.find("body").click #defocus
    click_button "Submit me!"

    expect(page).to have_field("title", with: "Title")
    expect(page).to have_field("description", with: "")
    expect(page).not_to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"can\'t be blank")]')

    expect(TestModel.last.description).to eq(value)
  end

  describe "Form Select Component" do

    describe "Dropdown" do

      it "takes an array of options or hash and submits selected item" do

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"]
                form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        select "Array Option 2", from: "my-array-test-dropdown"
        select "Hash Option 2", from: "my-hash-test-dropdown"
        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "2" }))

      end

      it "can be initialized with value" do

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
                form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: "1"
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        expect(page).to have_field("my-array-test-dropdown", with: "Array Option 1")
        expect(page).to have_field("my-hash-test-dropdown", with: "1")

        select "Array Option 2", from: "my-array-test-dropdown"
        select "Hash Option 2", from: "my-hash-test-dropdown"
        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "2" }))

      end

      it "can be mapped to an Active Record Model Array Enum" do

        Object.send(:remove_const, :TestModel)

        class TestModel < ApplicationRecord

          enum status: [ :active, :archived ]

        end

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
          end

          def response
            components {
              form form_config, :include do
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

    end

    describe "Checkbox" do

      it "takes an array of options or hash and submits (multiple) selected item(s)" do

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-checkbox", key: :array_input, type: :checkbox, options: ["Array Option 1","Array Option 2"]
                form_select id: "my-hash-test-checkbox", key: :hash_input, type: :checkbox, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: ["Array Option 2"], hash_input: ["1", "2"] }))

      end

      it "can be initialized by (multiple) item(s)" do

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-checkbox", key: :array_input, type: :checkbox, options: ["Array Option 1","Array Option 2"], init: ["Array Option 1", "Array Option 2"]
                form_select id: "my-hash-test-checkbox", key: :hash_input, type: :checkbox, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: ["2"]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: ["Array Option 1", "Array Option 2"], hash_input: ["2"] }))

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

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.some_data = ["Array Option 2"]
            @test_model.more_data = ["my_second_key"]
          end

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-checkbox", key: :some_data, type: :checkbox, options: TestModel.array_options
                form_select id: "my-hash-test-checkbox", key: :more_data, type: :checkbox, options: TestModel.hash_options
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-radio", key: :array_input, type: :radio, options: ["Array Option 1","Array Option 2"]
                form_select id: "my-hash-test-radio", key: :hash_input, type: :radio, options: { "1": "Hash Option 1", "2": "Hash Option 2" }
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "1" }))

      end

      it "can be initialized by (multiple) item(s)" do

        class ExamplePage < Page::Cell::Page

          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-radio", key: :array_input, type: :radio, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
                form_select id: "my-hash-test-radio", key: :hash_input, type: :radio, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, init: "2"
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        expect(page).to have_field('Array Option 1', checked: true)
        expect(page).to have_field('Array Option 2', checked: false)
        expect(page).to have_field('Hash Option 1', checked: false)
        expect(page).to have_field('Hash Option 2', checked: true)

        click_button "Submit me!"

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 1", hash_input: "2" }))

      end

      it "can be mapped to an Active Record Model Array Enum" do

        Object.send(:remove_const, :TestModel)

        class TestModel < ApplicationRecord

          enum status: [ :active, :archived ]

        end

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

      it "can be mapped to an Active Record Model Hash Enum" do

        Object.send(:remove_const, :TestModel)

        class TestModel < ApplicationRecord

          enum status: [ :active, :archived ]

        end

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

      it "can be mapped to Active Record Model Errors" do

        Object.send(:remove_const, :TestModel)

        class TestModel < ApplicationRecord

          enum status: { active: 0, archived: 1 }

        end

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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

        class ExamplePage < Page::Cell::Page

          def prepare
            @test_model = TestModel.new
            @test_model.status = "active"
          end

          def response
            components {
              form form_config, :include do
                form_input id: "description", key: :description, type: :text
                # TODO: Provide better Enum Options API
                form_select id: "status", key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
                form_submit do
                  button text: "Submit me!"
                end
              end
            }
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
  end

end
