require 'rails_vue_js_spec_helper'
require_relative "../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do

  before :all do
    class BasePage < Matestack::Ui::Page
      def response
        matestack_form form_config, :include do
          form_input id: "my-test-input", key: :foo, type: :text
          button text: "Submit me!"
        end
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: async_request_success_form_test_path(id: 42),
        }
      end
    end

    Rails.application.routes.append do
      post '/success_form_test/:id', to: 'form_test#success_submit', as: 'async_request_success_form_test'
      post '/success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'async_request_success_form_test_with_transition'
      post '/failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'async_request_failure_form_test_with_transition'
      post '/success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'async_request_success_form_test_with_redirect'
      post '/failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'async_request_failure_form_test_with_redirect'
      post '/failure_form_test/:id', to: 'form_test#failure_submit', as: 'async_request_failure_form_test'
      post '/model_form_test', to: 'model_form_test#model_submit', as: 'async_request_model_form_test'
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  describe 'async submit' do
    before :all do
      class BaseExamplePage < BasePage
      end
    end

    it "Example 1 - Async submit request with clientside payload" do
      visit "/base_example"
      fill_in "my-test-input", with: "bar"
      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(my_object: { foo: "bar" }))
      click_button "Submit me!"
    end

    it "Example 2 - Async submit request and clears inputs on success" do
      visit "/base_example"
      fill_in "my-test-input", with: "bar"
      expect(find_field("my-test-input").value).to eq "bar"
      click_button "Submit me!"
      expect(find_field("my-test-input").value).to eq ""
    end

  end

  describe 'async emit' do

    it "Example 1 - Async submit request with success event" do
      class BaseExamplePage < BasePage
        def response
          super
          toggle show_on: "my_form_success", id: 'async-form' do
            plain "{{vc.event.data.message}}"
          end
        end

        def form_config
          super.merge(success: { emit: "my_form_success" })
        end
      end

      visit "/base_example"
      fill_in "my-test-input", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form submitted successfully")
    end

    it "Example 3 - Async submit request with failure event" do
      class BaseExamplePage < BasePage
        def response
          super
          toggle show_on: "my_form_failure", id: 'async-form' do
            plain "{{vc.event.data.message}}"
            plain "{{vc.event.data.errors}}"
          end
        end

        def form_config
          super.merge(path: async_request_failure_form_test_path(id: 42), failure: { emit: "my_form_failure" })
        end
      end

      visit "/base_example"
      fill_in "my-test-input", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form had errors")
      expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]")
    end

  end

end
