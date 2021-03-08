require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
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

  describe "Async submit update request with success, which does not reset the input fields" do
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
          toggle show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          toggle show_on: "update_successful", hide_after: 5000, id: 'async-form-successful' do
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
        include Matestack::Ui::Core::Helper

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

  describe "Async submit with success configured to reset the input fields" do
    # https://github.com/matestack/matestack-ui-core/pull/314#discussion_r362826471

    before do
      class SearchPage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: 'query', key: :query, type: :text
            form_submit { button text: "Search" }
          end
          toggle show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          toggle show_on: "submission_successful", hide_after: 5000, id: 'async-form-successful' do
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
        include Matestack::Ui::Core::Helper

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

  describe "Async submit with success configured not to reset the input fields" do
    # https://github.com/matestack/matestack-ui-core/pull/314#discussion_r362826471

    before do
      class SearchPage < Matestack::Ui::Page
        def response
          form form_config, :include do
            form_input id: 'query', key: :query, type: :text
            form_submit { button text: "Search" }
          end
          toggle show_on: "form_has_errors", hide_after: 5000, id: 'async-form-errors' do
            plain "Form has errors"
          end
          toggle show_on: "submission_successful", hide_after: 5000, id: 'async-form-successful' do
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
        include Matestack::Ui::Core::Helper

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


  describe "Usage on Component Level" do

    it "Async submit request with clientside payload from component-level" do
      module Components end

      class Components::SomeComponent < Matestack::Ui::Component
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

  describe "Range input" do
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

end
