require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "form_textarea_spec" do
        post '/textarea_success_form_test', to: 'form_test#success_submit', as: 'textarea_success_form_test'
        post '/textarea_failure_form_test/:id', to: 'form_test#failure_submit', as: 'textarea_failure_form_test'
        post '/textarea_model_form_test', to: 'model_form_test#model_submit', as: 'textarea_model_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  describe "textarea" do

    it "can be submitted dynamically without page reload" do
      class SomeComponent < Matestack::Ui::Component
        def response
          form_textarea key: :bar, id: "my-other-test-input"
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
          toggle show_on: "form_submitted", id: 'async-form' do
            plain "form submitted!"
          end
        end

        def some_partial
          form_textarea key: :foo, id: "my-test-input"
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: "form_textarea_spec/textarea_success_form_test",
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

  describe 'textarea component' do

    it "Example 1 - Supports 'text', 'password', 'number', 'email', 'textarea', 'range' type" do
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_textarea id: "textarea-input", key: :textarea_input
            form_submit do
              button text: "Submit me!"
            end
          end
        end

        def form_config
          {
            for: :my_object,
            method: :post,
            path: :textarea_success_form_test_path,
            params: {
              id: 42
            }
          }
        end
      end

      visit "/example"
      fill_in "textarea-input", with: "Hello \n World!"
      expect_any_instance_of(FormTestController).to receive(:expect_params).with(hash_including(
        my_object: {
          textarea_input: "Hello \n World!",
        }
      ))
      click_button "Submit me!"
    end

    it "can be initialized with value" do
      class ExamplePage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_textarea id: "textarea", key: :textarea, init: "some value"
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :textarea_success_form_test_path,
            params: {
              id: 42
            }
          }
        end
      end

      visit "/example"
      expect(page).to have_field("textarea", with: "some value")
    end

    it "can get a label" do
      class ExamplePage < Matestack::Ui::Page
        def response
            form form_config, :include do
              form_textarea id: "textarea", key: :textarea, label: "some label"
              form_submit do
                button text: "Submit me!"
              end
            end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :textarea_success_form_test_path,
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
            form_textarea id: "textarea", key: :foo
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          {
            for: :my_object,
            method: :post,
            path: :textarea_failure_form_test_path,
            params: {
              id: 42
            }
          }
        end
      end
  
      visit "/example"
      fill_in "textarea", with: "text"
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
            form_textarea id: "title", key: :title
            form_textarea id: "description", key: :description
            form_submit do
              button text: "Submit me!"
            end
          end
        end
  
        def form_config
          {
            for: @test_model,
            method: :post,
            path: :textarea_model_form_test_path
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
