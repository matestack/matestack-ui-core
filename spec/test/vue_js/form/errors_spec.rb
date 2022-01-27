require 'rails_vue_js_spec_helper'
require_relative "../support/test_controller"
require_relative "support/form_test_controller"
require_relative "support/model_form_test_controller"
include VueJsSpecUtils

describe "form errors", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "form_form_error_error_spec" do
        post '/form_error_failure_form_test/:id', to: 'form_test#failure_submit', as: 'form_error_failure_form_test'
      end
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end

  it "should render error messages" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          form_textarea id: "textarea", key: :foo, type: :text
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: form_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    fill_in "textarea", with: "area"
    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid', count: 2)
    expect(page).to have_selector('#text-input.error')
    expect(page).to have_selector('#textarea.error')
    expect(page).to have_selector("#text-input + .errors > .error", text: "seems to be invalid")
    expect(page).to have_selector("#textarea + .errors > .error", text: "seems to be invalid")
    expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]', count: 2)
  end

  it "should reset error messages properly when missing data is provided" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          button "Submit me!"
          plain "Errors: {{vc.errors}}"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: form_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"

    fill_in "text-input", with: "text"

    click_button "Submit me!"

    expect(page).to have_content('Errors: { "foo": [ "seems to be invalid" ] }')

    fill_in "text-input", with: "texttext"

    page.find("#text-input").native.send_keys :tab

    expect(page).to have_content('Errors: {}')

    expect(page).not_to have_content('seems to be invalid')
    expect(page).not_to have_selector('#text-input.error')
    expect(page).not_to have_selector("#text-input + .errors > .error", text: "seems to be invalid")
  end

  it "can turn off error messages with form config and turn explicit on" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          form_textarea id: "textarea", key: :foo, type: :text, errors: { wrapper: { tag: :span }, tag: :span }
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: form_error_failure_form_test_path(id: 42),
          errors: false
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    fill_in "textarea", with: "area"
    click_button "Submit me!"
    expect(page).to have_selector('#text-input.error')
    expect(page).to have_selector('#textarea.error')
    expect(page).to have_content('seems to be invalid', count: 1)
    expect(page).not_to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
    expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"seems to be invalid")]')
  end

  it "lets you turn errors of component based" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          form_textarea id: "textarea", key: :foo, type: :text, errors: false
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: form_error_failure_form_test_path(id: 42),
          errors: {
            input: { class: 'my-error' }
          }
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    fill_in "textarea", with: "area"
    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid', count: 1)
    expect(page).to have_selector('#text-input.my-error')
    expect(page).not_to have_selector('#text-input.error')
    expect(page).to have_selector('#textarea.my-error')
    expect(page).not_to have_selector('#textarea.error')
    expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]', count: 1)
  end

  it "lets you customize errors and errors wrapper" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_input id: "text-input", key: :foo, type: :text
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: form_error_failure_form_test_path(id: 42),
          errors: {
            wrapper: {
              tag: :div,
              class: 'my-errors'
            },
            tag: :div,
            class: 'my-error'
          }
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_xpath('//div[@class="my-errors"]/div[@class="my-error" and contains(.,"seems to be invalid")]')
  end

end
