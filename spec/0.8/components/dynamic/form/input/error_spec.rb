require_relative "../../../../../support/utils"
require_relative "../../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "form input", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "form_text_input_error_error_spec" do
        post '/input_error_failure_form_test/:id', to: 'form_test#failure_submit', as: 'input_error_error_failure_form_test'
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
          path: :input_error_error_failure_form_test_path,
          params: {
            id: 42
          }
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_selector('#text-input.error')
    expect(page).to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"seems to be invalid")]')
  end

  it "can turn off error messages" do
    class ExamplePage < Matestack::Ui::Page
      def response
        form form_config, :include do
          form_input id: "text-input", key: :foo, type: :text, errors: false
          form_submit do
            button text: "Submit me!"
          end
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: :input_error_error_failure_form_test_path,
          params: {
            id: 42
          }
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    click_button "Submit me!"
    expect(page).not_to have_content('seems to be invalid')
    expect(page).not_to have_xpath('//span[@class="errors"]/span[@class="error" and contains(.,"seems to be invalid")]')
  end
  
  it "lets you customize errors" do
    class ExamplePage < Matestack::Ui::Page
      def response
        form form_config, :include do
          form_input id: "text-input", key: :foo, type: :text, errors: { wrapper: {}, tag: :div, class: 'my-error' }
          form_submit do
            button text: "Submit me!"
          end
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: :input_error_error_failure_form_test_path,
          params: {
            id: 42
          },
          errors: {
            input: { class: 'my-error' }
          }
        }
      end
    end

    visit "/example"
    fill_in "text-input", with: "text"
    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_selector('#text-input.my-error')
    expect(page).to have_xpath('//span[@class="errors"]/div[@class="my-error" and contains(.,"seems to be invalid")]')
  end
  
  it "lets you customize errors and errors wrapper" do
    class ExamplePage < Matestack::Ui::Page
      def response
        form form_config, :include do
          form_input id: "text-input", key: :foo, type: :text, errors: { 
            wrapper: { tag: :div, class: 'my-errors'}, tag: :div, class: 'my-error' 
          }
          form_submit do
            button text: "Submit me!"
          end
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: :input_error_error_failure_form_test_path,
          params: {
            id: 42
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