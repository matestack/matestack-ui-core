require_relative "../../../support/utils"
require_relative "../../../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    class EmitFormTestController < FormTestController
      def success_submit
        render json: { message: "server says: form submitted successfully" }, status: 200
      end
    end

    Rails.application.routes.prepend do
      post '/data_access_form_test', to: 'emit_form_test#success_submit', as: 'form_data_access_submit'
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(EmitFormTestController).to receive(:expect_params)
  end

  it "data is accessable within form without component in pure Vue.js" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          plain "{{ data }}"
          form_input key: :foo_input, type: :text, id: "foo-input"
          form_textarea key: :foo_textarea, type: :text, id: "foo-textarea"
          form_select key: :foo_select, options: [1, 2, 3], id: "foo-select", init: 2
          form_checkbox key: :foo_single_checkbox, id: "foo-single-checkbox"
          form_checkbox key: :foo_multi_checkbox, options: [1, 2, 3], id: "foo-multi-checkbox"
          form_radio key: :foo_radio, options: [1, 2, 3], id: "foo-radio-checkbox"
          button 'Submit me!'
        end
        toggle show_on: "form_submitted", id: 'async-form' do
          plain "form submitted!"
        end
      end

      def form_config
        return {
          for: :my_object,
          method: :post,
          path: form_data_access_submit_path,
          emit: "form_submitted"
        }
      end
    end

    visit '/example'

    expect(page).to have_content('{ "foo_input": null, "foo_textarea": null, "foo_single_checkbox": null, "foo_multi_checkbox": [], "foo_radio": null, "foo_select": 2 }')

    fill_in "foo-input", with: "1"
    fill_in "foo-textarea", with: "2"
    select "3", from: "foo-select"
    check "foo-single-checkbox_1"
    check "foo-multi-checkbox_1"
    check "foo-multi-checkbox_2"
    choose "foo-radio-checkbox_3"

    expect(page).to have_content('{ "foo_input": "1", "foo_textarea": "2", "foo_single_checkbox": true, "foo_multi_checkbox": [ 1, 2 ], "foo_radio": 3, "foo_select": 3 }')

    click_on "Submit me!"

    expect(page).to have_content('{ "foo_input": null, "foo_textarea": null, "foo_single_checkbox": null, "foo_multi_checkbox": [], "foo_radio": null, "foo_select": 2 }')

  end


end
