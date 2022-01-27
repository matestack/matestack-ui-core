require 'rails_vue_js_spec_helper'
require_relative "../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include VueJsSpecUtils

describe "Form Component", type: :feature, js: true do

  before :all do
    class RadioFormTestController < FormTestController
      def success_submit
        render json: { message: "server says: form submitted successfully" }, status: 200
      end

      def success_submit_with_transition
        render json: {
          message: "server says: form submitted successfully",
          transition_to: form_test_page_4_path(id: 42)
        }, status: 200
      end

      def failure_submit
        render json: {
          message: "server says: form had errors",
          errors: { foo: ["seems to be invalid"] }
        }, status: 400
      end
    end

    Rails.application.routes.append do
      post '/success_form_test/:id', to: 'radio_form_test#success_submit', as: 'form_select_radio_spec_success_form_test'
      post '/success_form_test_with_transition/:id', to: 'radio_form_test#success_submit_with_transition', as: 'form_select_radio_spec_success_form_test_with_transition'
      post '/failure_form_test/:id', to: 'radio_form_test#failure_submit', as: 'form_select_radio_spec_failure_form_test'
    end
    Rails.application.reload_routes!

    class RadioModelFormTestController < TestController
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
      post '/model_form_test', to: 'radio_model_form_test#model_submit', as: 'form_select_radio_spec_model_form_test'
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(RadioFormTestController).to receive(:expect_params)
  end

  describe "Radio Button" do

    it "generates unique names for each radio button group and value" do
      class ExamplePage < Matestack::Ui::Page
        def response
          matestack_form form_config do
            form_radio id: 'group-one-radio', key: :array_input_one, options: ['foo','bar']
            form_radio id: 'group-two-radio', key: :array_input_two, options: ['foo', 'bar']
            button text: 'Submit me!'
          end
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: form_select_radio_spec_success_form_test_path(id: 42),
          }
        end
      end

      visit '/example'
      expect(page).to have_selector('#group-one-radio_foo[name="array_input_one_foo"]')
      expect(page).to have_selector('#group-one-radio_bar[name="array_input_one_bar"]')
      expect(page).to have_selector('#group-two-radio_foo[name="array_input_two_foo"]')
      expect(page).to have_selector('#group-two-radio_bar[name="array_input_two_bar"]')
    end
  end

end
