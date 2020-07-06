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

      def success_submit_with_transition
        if params[:to_page].present?
          transition_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
        else
          transition_path = form_test_page_4_path(id: 42)
        end
        render json: {
          message: "server says: form submitted successfully",
          transition_to: transition_path
        }, status: 200
      end

      def failure_submit_with_transition
        if params[:to_page].present?
          transition_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
        else
          transition_path = form_test_page_4_path(id: 42)
        end
        render json: {
          message: "server says: form had errors",
          errors: { foo: ["seems to be invalid"] },
          transition_to: transition_path
        }, status: 400
      end

      def success_submit_with_redirect
        if params[:to_page].present?
          redirect_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
        else
          redirect_path = form_test_page_4_path(id: 42)
        end
        render json: {
          message: "server says: form submitted successfully",
          redirect_to: redirect_path
        }, status: 200
      end

      def failure_submit_with_redirect
        if params[:to_page].present?
          redirect_to_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
        else
          redirect_to_path = form_test_page_4_path(id: 42)
        end
        render json: {
          message: "server says: form had errors",
          errors: { foo: ["seems to be invalid"] },
          redirect_to: redirect_to_path
        }, status: 400
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
      post '/success_form_test_with_transition/:id', to: 'form_test#success_submit_with_transition', as: 'success_form_test_with_transition'
      post '/failure_form_test_with_transition/:id', to: 'form_test#failure_submit_with_transition', as: 'failure_form_test_with_transition'
      post '/success_form_test_with_redirect/:id', to: 'form_test#success_submit_with_redirect', as: 'success_form_test_with_redirect'
      post '/failure_form_test_with_redirect/:id', to: 'form_test#failure_submit_with_redirect', as: 'failure_form_test_with_redirect'
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
          }, status: :unprocessable_entity
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

    class ExamplePage < Matestack::Ui::Page

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

    expect_any_instance_of(FormTestController).to receive(:expect_params)
      .with(hash_including(my_object: { foo: "bar" }))

    click_button "Submit me!"

  end

  it "Example 2 - Async submit request and clears inputs on success" do

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

  it "Example 4 - Async submit request with success/failure transition" do
    class Apps::ExampleApp < Matestack::Ui::App

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

    class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

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

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

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
    # sleep
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
    expect(page).to have_content("\"foo\": [ \"seems to be invalid\" ]")

    expect(page).to have_content("This is Page 1")
    expect(page).to have_selector("body.not-reloaded")

  end

  it "Example 5 - Async submit request with success/failure transition determined by server response" do
    class Apps::ExampleApp < Matestack::Ui::App

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

    class Pages::ExampleApp::ExamplePage3 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 3"
          form form_config, :include do
            form_input id: "my-test-input-on-page-3", key: :foo, type: :text
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
          path: :success_form_test_with_transition_path,
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
        }
      end

    end

    class Pages::ExampleApp::ExamplePage4 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 4"

          form form_config, :include do
            form_input id: "my-test-input-on-page-4", key: :foo, type: :text
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
          path: :failure_form_test_with_transition_path,
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
        }
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page3
        responder_for(Pages::ExampleApp::ExamplePage3)
      end

      def page4
        responder_for(Pages::ExampleApp::ExamplePage4)
      end

    end

    Rails.application.routes.append do
      scope :form_test do
        get 'page3', to: 'example_app_pages#page3', as: 'form_test_page_3'
        get 'page4/:id', to: 'example_app_pages#page4', as: 'form_test_page_4'
      end
    end
    Rails.application.reload_routes!

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
    class Apps::ExampleApp < Matestack::Ui::App

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

    class Pages::ExampleApp::ExamplePage5 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 5"
          form form_config, :include do
            form_input id: "my-test-input-on-page-5", key: :foo, type: :text
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
          path: :success_form_test_with_redirect_path,
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
        }
      end

    end

    class Pages::ExampleApp::ExamplePage6 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 6"
          form form_config, :include do
            form_input id: "my-test-input-on-page-6", key: :foo, type: :text
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
          path: :failure_form_test_with_redirect_path,
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
        }
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page5
        responder_for(Pages::ExampleApp::ExamplePage5)
      end

      def page6
        responder_for(Pages::ExampleApp::ExamplePage6)
      end

    end

    Rails.application.routes.append do
      scope :form_test do
        get 'page5', to: 'example_app_pages#page5', as: 'form_test_page_5'
        get 'page6/:id', to: 'example_app_pages#page6', as: 'form_test_page_6'
      end
    end
    Rails.application.reload_routes!

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
    class Apps::ExampleApp < Matestack::Ui::App

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

    class Pages::ExampleApp::Page7 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 7"
          form form_config, :include do
            form_input id: "my-test-input-on-page-7", key: :foo, type: :text
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
            redirect: {
              path: :form_test_page_8_path,
              params: {
                id: 42
              }
            }
          }
        }
      end

    end

    class Pages::ExampleApp::Page8 < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 8"
          form form_config, :include do
            form_input id: "my-test-input-on-page-8", key: :foo, type: :text
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
            redirect: {
              path: :form_test_page_7_path
            }
          }
        }
      end

    end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page7
        responder_for(Pages::ExampleApp::Page7)
      end

      def page8
        responder_for(Pages::ExampleApp::Page8)
      end

    end

    Rails.application.routes.append do
      scope :form_test do
        get 'page7', to: 'example_app_pages#page7', as: 'form_test_page_7'
        get 'page8/:id', to: 'example_app_pages#page8', as: 'form_test_page_8'
      end
    end
    Rails.application.reload_routes!

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

  describe "Example 6 - Async submit update request with success, which does not reset the input fields" do
    # https://github.com/basemate/matestack-ui-core/issues/304

    # This example uses the `TestModel` with attributes `title` and `description`
    # defined in `spec/dummy/app/models/test_model.rb`.

    before do
      class Pages::TestModelPage < Matestack::Ui::Page
        def response
          components {
            form form_config, :include do
              form_input id: 'title', key: :title, type: :text
              form_input id: 'description', key: :description, type: :text
              form_submit { button text: "Save" }
            end
            async show_on: "form_has_errors", hide_after: 5000 do
              plain "Form has errors"
            end
            async show_on: "update_successful", hide_after: 5000 do
              plain "Update successful"
            end
          }
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
          responder_for Pages::TestModelPage
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
      class Pages::SearchPage < Matestack::Ui::Page
        def response
          components {
            form form_config, :include do
              form_input id: 'query', key: :query, type: :text
              form_submit { button text: "Search" }
            end
            async show_on: "form_has_errors", hide_after: 5000 do
              plain "Form has errors"
            end
            async show_on: "submission_successful", hide_after: 5000 do
              plain "Submission successful"
            end
          }
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
          responder_for Pages::SearchPage
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
      class Pages::SearchPage < Matestack::Ui::Page
        def response
          components {
            form form_config, :include do
              form_input id: 'query', key: :query, type: :text
              form_submit { button text: "Search" }
            end
            async show_on: "form_has_errors", hide_after: 5000 do
              plain "Form has errors"
            end
            async show_on: "submission_successful", hide_after: 5000 do
              plain "Submission successful"
            end
          }
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
          responder_for Pages::SearchPage
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

  describe "Form Input Component" do

    it "Example 1 - Supports 'text', 'password', 'number', 'email', 'textarea', 'range' type" do

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            form form_config, :include do
              form_input id: "text-input",      key: :text_input, type: :text
              form_input id: "email-input",     key: :email_input, type: :email
              form_input id: "password-input",  key: :password_input, type: :password
              form_input id: "number-input",    key: :number_input, type: :number
              form_input id: "textarea-input",  key: :textarea_input, type: :textarea
              form_input id: "range-input",     key: :range_input, type: :range
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
      fill_in "range-input", with: 10

      expect_any_instance_of(FormTestController).to receive(:expect_params)
        .with(hash_including(
          my_object: {
            text_input: "text",
            email_input: "name@example.com",
            password_input: "secret",
            number_input: 123,
            textarea_input: "Hello \n World!",
            range_input: "10"
          }
        ))

      click_button "Submit me!"

    end

  end

  it "can be initialized with value" do

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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

    class ExamplePage < Matestack::Ui::Page

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
    #page.save_screenshot
    #p page.driver.browser.manage.logs.get(:browser)
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

        class ExamplePage < Matestack::Ui::Page

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

        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "2" }))

        click_button "Submit me!"
      end

      it "can be initialized with value" do

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

      it "can have a class" do
        class ExamplePage < Matestack::Ui::Page
          def response
            components {
              form form_config, :include do
                form_select id: "my-array-test-dropdown", key: :array_input, type: :dropdown, options: ["Array Option 1","Array Option 2"], class: "form-control"
                form_select id: "my-hash-test-dropdown", key: :hash_input, type: :dropdown, options: { "1": "Hash Option 1", "2": "Hash Option 2" }, class: "form-control"
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

        expect(page).to have_css("#my-array-test-dropdown.form-control")
        expect(page).to have_css("#my-hash-test-dropdown.form-control")
      end
    end

    describe "Checkbox" do

      it "takes an array of options or hash and submits (multiple) selected item(s)" do

        class ExamplePage < Matestack::Ui::Page

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


        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: ["Array Option 2"], hash_input: ["1", "2"] }))

        click_button "Submit me!"

      end

      it "can be initialized by (multiple) item(s)" do

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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


        expect_any_instance_of(FormTestController).to receive(:expect_params)
          .with(hash_including(my_object: { array_input: "Array Option 2", hash_input: "1" }))

        click_button "Submit me!"
      end

      it "can be initialized by (multiple) item(s)" do

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

        class ExamplePage < Matestack::Ui::Page

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

    describe "Usage on Component Level" do

      it "Example 1 - Async submit request with clientside payload from component-level" do

        module Components end

        class Components::SomeComponent < Matestack::Ui::StaticComponent

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

          register_self_as(:custom_some_component)
        end

        class ExamplePage < Matestack::Ui::Page

          def response
            components {
              div do
                custom_some_component
              end
            }
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
        components {
          form form_config, :include do
            form_input id: "range-input",
              key: :range_input, type: :range,
              init: 3, min: 0, max: 10, step: 1, list: "my_list"
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

    expect(page).to have_field("range-input", with: "3")
    expect(page).to have_selector('#range-input[min="0"][max="10"][step="1"][list="my_list"]')

  end

end
