require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
require_relative "../support/form_test_controller"
require_relative "../support/model_form_test_controller"
include Utils

describe "form select", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "form_text_select_error_error_spec" do
        post '/select_error_failure_form_test/:id', to: 'form_test#failure_submit', as: 'select_error_error_failure_form_test'
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
          form_select key: :foo, id: "foo", options: ["Array Option 1","Array Option 2"]
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: select_error_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"

    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_selector('#foo.error')
    expect(page).to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
  end

  it "can turn off error messages" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_select key: :foo, id: "foo", options: ["Array Option 1","Array Option 2"], errors: false
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: select_error_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"

    click_button "Submit me!"
    expect(page).not_to have_content('seems to be invalid')
    expect(page).not_to have_xpath('//div[@class="errors"]/div[@class="error" and contains(.,"seems to be invalid")]')
  end

  it "lets you customize errors" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_select key: :foo, id: "foo", options: ["Array Option 1","Array Option 2"], errors: { wrapper: {}, tag: :div, class: 'my-error' }
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: select_error_error_failure_form_test_path(id: 42),
          errors: {
            input: { class: 'my-error' }
          }
        }
      end
    end

    visit "/example"

    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_selector('#foo.my-error')
    expect(page).to have_xpath('//div[@class="errors"]/div[@class="my-error" and contains(.,"seems to be invalid")]')
  end

  it "lets you customize errors and errors wrapper" do
    class ExamplePage < Matestack::Ui::Page
      def response
        matestack_form form_config do
          form_select key: :foo, id: "foo", options: ["Array Option 1","Array Option 2"], errors: {
            wrapper: { tag: :div, class: 'my-errors'}, tag: :div, class: 'my-error'
          }
          button "Submit me!"
        end
      end

      def form_config
        {
          for: :my_object,
          method: :post,
          path: select_error_error_failure_form_test_path(id: 42),
        }
      end
    end

    visit "/example"

    click_button "Submit me!"
    expect(page).to have_content('seems to be invalid')
    expect(page).to have_xpath('//div[@class="my-errors"]/div[@class="my-error" and contains(.,"seems to be invalid")]')
  end

end
