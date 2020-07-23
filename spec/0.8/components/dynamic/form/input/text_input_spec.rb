require_relative "../../../../../support/utils"
require_relative "../../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  
  before :all do
    Rails.application.routes.append do
      scope "form_text_input_spec" do
        post '/input_success_form_test', to: 'form_test#success_submit', as: 'input_success_form_test'
        post '/input_failure_form_test/:id', to: 'form_test#failure_submit', as: 'input_failure_form_test'
        post '/input_model_form_test', to: 'model_form_test#model_submit', as: 'input_model_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  describe "text input" do

    it "can be submitted dynamically without page reload" do
      class SomeComponent < Matestack::Ui::StaticComponent
        def response
          form_input key: :bar, type: :text, id: "my-other-test-input"
        end

        register_self_as(:some_component)
      end

      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config do
            div do
              some_partial
            end
            some_component
            form_submit do
              button text: 'Submit me!'
            end
          end
          async show_on: "form_submitted", id: 'async-form' do
            plain "form submitted!"
          end
        end

        def some_partial
          form_input key: :foo, type: :text, id: "my-test-input"
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: "form_text_input_spec/input_success_form_test",
            emit: "form_submitted"
          }
        end
      end

      visit '/example'
      fill_in "my-test-input", with: "bar"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { bar: nil, foo: "bar" }))

      click_button "Submit me!"
      expect(page).to have_content("form submitted!")
    end

  end

  describe 'input' do

    it "Example 1 - Supports 'text', 'password', 'number', 'email', 'textarea', 'range' type" do
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: "text-input",      key: :text_input, type: :text
            form_input id: "email-input",     key: :email_input, type: :email
            form_input id: "password-input",  key: :password_input, type: :password
            form_input id: "number-input",    key: :number_input, type: :number
            # form_input id: "textarea-input",  key: :textarea_input, type: :textarea # TODO textarea will be moved
            form_input id: "range-input",     key: :range_input, type: :range
            form_submit do
              button text: "Submit me!"
            end
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: :input_success_form_test_path,
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
      # fill_in "textarea-input", with: "Hello \n World!"
      fill_in "range-input", with: 10
      expect_any_instance_of(FormTestController).to receive(:expect_params).with(hash_including(
        my_object: {
          text_input: "text",
          email_input: "name@example.com",
          password_input: "secret",
          number_input: 123,
          # textarea_input: "Hello \n World!",
          range_input: "10"
        }
      ))
      click_button "Submit me!"
    end

    it "can be initialized with value" do
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: "text-input", key: :text_input, type: :text, init: "some value"
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :input_success_form_test_path,
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
      class ExamplePage < Matestack::Ui::Page
        def response
            form form_config, :include do
              form_input id: "text-input", key: :text_input, type: :text, placeholder: "some placeholder"
              form_submit do
                button text: "Submit me!"
              end
            end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :input_success_form_test_path,
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
      class ExamplePage < Matestack::Ui::Page
        def response
            form form_config, :include do
              form_input id: "text-input", key: :text_input, type: :text, label: "some label"
              form_submit do
                button text: "Submit me!"
              end
            end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :input_success_form_test_path,
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
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: "text-input", key: :foo, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :input_failure_form_test_path,
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
      Object.send(:remove_const, :TestModel)
  
      class TestModel < ApplicationRecord
        validates :description, presence:true
      end
  
      class ExamplePage < Matestack::Ui::Page
        def prepare
          @test_model = TestModel.new
          @test_model.title = "Title"
        end
  
        def response
          form form_config, :include do
            form_input id: "title", key: :title, type: :text
            form_input id: "description", key: :description, type: :text
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          return {
            for: @test_model,
            method: :post,
            path: :input_model_form_test_path
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

  end

end
