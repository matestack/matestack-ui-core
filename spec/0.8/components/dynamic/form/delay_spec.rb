require_relative "../../../../support/utils"
require_relative "../../../../support/test_controller"
include Utils

describe "Form Component", type: :feature, js: true do

  before :all do
    class FormTestController < TestController
      def success_submit
        receive_timestamp = DateTime.now.strftime('%Q')
        render json: { received_at: receive_timestamp }, status: 200
      end
    end

    Rails.application.routes.append do
      post '/success_form_test', to: 'form_test#success_submit', as: 'form_delay_success_submit'
    end
    Rails.application.reload_routes!
  end

  before :each do
    allow_any_instance_of(FormTestController).to receive(:expect_params)
  end


  describe "delay attribute" do

    it "if set, delays form submit" do

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            form form_config, :include do
              form_input key: :foo, type: :text, id: "my-test-input"
              form_submit do
                button text: 'Submit me!'
              end
            end
            div id: "timestamp" do
              async show_on: "form_submitted_successfully" do
                plain "{{event.data.received_at}}"
              end
            end
          }
        end

        def form_config
          return {
            for: :my_object,
            method: :post,
            path: :form_delay_success_submit_path,
            delay: 1000,
            success: {
              emit: "form_submitted_successfully"
            }
          }
        end

      end

      visit '/example'

      submit_timestamp = DateTime.now.strftime('%Q').to_i
      fill_in "my-test-input", with: submit_timestamp
      click_button "Submit me!"

      sleep 1.5

      element = page.find("#timestamp")
      receive_timestamp = element.text.to_i

      expect(receive_timestamp - submit_timestamp).to be > 1000

    end

  end

end
