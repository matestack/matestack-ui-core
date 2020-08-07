require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      post '/async_transition_success_form_test/:id', to: 'form_test#success_submit', as: 'async_transition_success_form_test'
      post '/async_transition_success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'async_transition_success_form_test_with_transition'
      post '/async_transition_failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'async_transition_failure_form_test_with_transition'
      post '/async_transition_success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'async_transition_success_form_test_with_redirect'
      post '/async_transition_failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'async_transition_failure_form_test_with_redirect'
      post '/async_transition_failure_form_test/:id', to: 'form_test#failure_submit', as: 'async_transition_failure_form_test'
      post '/async_transition_model_form_test', to: 'model_form_test#model_submit', as: 'async_transition_model_form_test'
      scope :form_test do
        get 'page1', to: 'example_app_pages#page1', as: 'form_test_page_1'
        get 'page2/:id', to: 'example_app_pages#page2', as: 'form_test_page_2'
        get 'page3', to: 'example_app_pages#page3', as: 'form_test_page_3'
        get 'page4/:id', to: 'example_app_pages#page4', as: 'form_test_page_4'
        get 'page5', to: 'example_app_pages#page5', as: 'form_test_page_5'
        get 'page6/:id', to: 'example_app_pages#page6', as: 'form_test_page_6'
        get 'page7', to: 'example_app_pages#page7', as: 'form_test_page_7'
        get 'page8/:id', to: 'example_app_pages#page8', as: 'form_test_page_8'
      end
    end
    Rails.application.reload_routes!

    module Example
    end
    
    class Example::App < Matestack::Ui::App
      def response
        heading size: 1, text: "My Example App Layout"
        main do
          page_content
        end
        toggle show_on: "my_form_success", hide_after: 300, id: 'async-form-success' do
          plain "{{event.data.message}}"
        end
        toggle show_on: "my_form_failure", hide_after: 300, id: 'async-form-failure' do
          plain "{{event.data.message}}"
          plain "{{event.data.errors}}"
        end
      end
    end
    
    module Example::Pages
    end
    
    class BasePage < Matestack::Ui::Page
      def form_partial(number)
        heading size: 2, text: "This is Page #{number}"
        form form_config, :include do
          form_input id: "my-test-input-on-page-#{number}", key: :foo, type: :text
          form_submit do
            button text: "Submit me!"
          end
        end
      end
    
      def form_config
        {
          for: :my_object,
          method: :post,
          path: :async_transition_success_form_test_path,
          params: {
            id: 42
          },
        }
      end
    end
    
    class Example::Pages::ExamplePage1 < BasePage
      def response
        form_partial(1)
      end

      def form_config
        super.merge(
          success: {
            emit: "my_form_success",
            transition: {
              path: :form_test_page_2_path,
              params: {
                id: 42
              }
            }
          }
        )
      end
    end
    
    class Example::Pages::ExamplePage2 < BasePage
      def response
        form_partial(2)
      end
    
      def form_config
        super.merge(
          path: :async_transition_failure_form_test_path,
          failure: {
            emit: "my_form_failure",
            transition: {
              path: :form_test_page_1_path
            }
          }
        )
      end
    end
    
    class Example::Pages::ExamplePage3 < BasePage
      def response
        form_partial(3)
      end
    
      def form_config
        super.merge(
          path: :async_transition_success_form_test_with_transition_path,
          params: {
            id: 42,
            to_page: 4
          },
          success: {
            emit: "my_form_success",
            transition: {
              follow_response: true
            }
          }
        )
      end
    end
    
    class Example::Pages::ExamplePage4 < BasePage
      def response
        form_partial(4)
      end
    
      def form_config
        super.merge(
          path: :async_transition_failure_form_test_with_transition_path,
          params: {
            id: 42,
            to_page: 3
          },
          failure: {
            emit: "my_form_failure",
            transition: {
              follow_response: true
            }
          }
        )
      end
    end

    class Example::Pages::ExamplePage5 < BasePage
      def response
        form_partial(5)
      end

      def form_config
        super.merge(
          path: :async_transition_success_form_test_with_redirect_path,
          params: {
            id: 42,
            to_page: 6
          },
          success: {
            emit: "my_form_success",
            redirect: {
              follow_response: true
            }
          }
        )
      end
    end

    class Example::Pages::ExamplePage6 < BasePage
      def response
        form_partial(6)
      end

      def form_config
        super.merge(
          path: :async_transition_failure_form_test_with_redirect_path,
          params: {
            id: 42,
            to_page: 5
          },
          failure: {
            emit: "my_form_success",
            redirect: {
              follow_response: true
            }
          }
        )
      end
    end

    class Example::Pages::ExamplePage7 < BasePage
      def response
        form_partial(7)
      end

      def form_config
        super.merge(
          success: {
            emit: "my_form_success",
            redirect: {
              path: :form_test_page_8_path,
              params: {
                id: 42
              }
            }
          }
        )
      end
    end

    class Example::Pages::ExamplePage8 < BasePage
      def response
        form_partial(8)
      end

      def form_config
        super.merge(
          path: :async_transition_failure_form_test_path,
          failure: {
            emit: "my_form_failure",
            redirect: {
              path: :form_test_page_7_path
            }
          }
        )
      end
    end
    
    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper
      matestack_app Example::App
    
      def page1
        render(Example::Pages::ExamplePage1)
      end
    
      def page2
        render(Example::Pages::ExamplePage2)
      end
    
      def page3
        render(Example::Pages::ExamplePage3)
      end
    
      def page4
        render(Example::Pages::ExamplePage4)
      end

      def page5
        render(Example::Pages::ExamplePage5)
      end

      def page6
        render(Example::Pages::ExamplePage6)
      end

      def page7
        render(Example::Pages::ExamplePage7)
      end

      def page8
        render(Example::Pages::ExamplePage8)
      end
    end
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  describe 'async transition' do

    it 'Example 1 - Async submit request with success/failure transition' do
      visit "form_test/page1"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 1")

      fill_in "my-test-input-on-page-1", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form submitted successfully")
      expect(page).to have_content("This is Page 2")
      expect(page).to have_selector("body.not-reloaded")

      fill_in "my-test-input-on-page-2", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form had errors")
      expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]", wait: 3)
      expect(page).to have_content("This is Page 1")
      expect(page).to have_selector("body.not-reloaded")
    end

    it "Example 5 - Async submit request with success/failure transition determined by server response" do
      visit "form_test/page3"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 3")
  
      fill_in "my-test-input-on-page-3", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form submitted successfully")
      expect(page).to have_content("This is Page 4")
      expect(page).to have_selector("body.not-reloaded")
  
      fill_in "my-test-input-on-page-4", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("server says: form had errors")
      expect(page).to have_content("This is Page 3")
      expect(page).to have_selector("body.not-reloaded")
    end

    it "Example 5.1 - Async submit request with success/failure redirect determined by server response" do
      visit "form_test/page5"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 5")
  
      fill_in "my-test-input-on-page-5", with: "bar"
      click_button "Submit me!"
      # expect(page).to have_content("server says: form submitted successfully")
      expect(page).to have_content("This is Page 6")
      expect(page).not_to have_selector("body.not-reloaded")
  
      fill_in "my-test-input-on-page-6", with: "bar"
      click_button "Submit me!"
      expect(page).to have_content("This is Page 5")
      expect(page).not_to have_selector("body.not-reloaded")
    end

    it "Example 5.2 - Async submit request with success redirect" do
      visit "form_test/page7"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 7")
  
      fill_in "my-test-input-on-page-7", with: "bar"
      click_button "Submit me!"
      # expect(page).to have_content("server says: form submitted successfully")
      expect(page).to have_content("This is Page 8")
      expect(page).not_to have_selector("body.not-reloaded")
  
      fill_in "my-test-input-on-page-8", with: "bar"
      click_button "Submit me!"
      # expect(page).to have_content("server says: form had errors")
      # expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]")
      expect(page).to have_content("This is Page 7")
      expect(page).not_to have_selector("body.not-reloaded")
    end

  end

end