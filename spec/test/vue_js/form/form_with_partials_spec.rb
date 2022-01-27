require 'rails_vue_js_spec_helper'
require_relative "../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include VueJsSpecUtils

describe "form component", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "form_text_input_error_spec" do
        post '/input_error_failure_form_test/:id', to: 'form_test#failure_submit', as: 'input_error_failure_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  it "should work with partials" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          input_partial
          button "Submit me!"
        end
      end

      def input_partial
        form_input id: "input-partial", key: :bar, type: :text
        inception
      end

      def inception
        form_input id: "inception", key: :baz, type: :text
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: input_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"
    expect_any_instance_of(FormTestController).to receive(:expect_params)
      .with(
        hash_including(my_object: {
          bar: 'from partial',
          baz: 'partial in partial',
          foo: 'text',
        }
      )
    )
    expect(page).to have_selector('#text-input')
    expect(page).to have_selector('#input-partial')
    expect(page).to have_selector('#inception')
    fill_in "text-input", with: "text"
    fill_in "input-partial", with: "from partial"
    fill_in "inception", with: "partial in partial"
    click_button "Submit me!"
  end

end
