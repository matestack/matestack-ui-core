require 'rails_vue_js_spec_helper'
require_relative "../support/test_controller"
include VueJsSpecUtils

describe "Action Component", type: :feature, js: true do

  before :each do
    class ActionTestController < TestController
      def test
        receive_timestamp = DateTime.now.strftime('%Q')
        render json: { received_at: receive_timestamp }, status: 200
      end
    end

    allow_any_instance_of(ActionTestController).to receive(:expect_params)
  end

  describe "delay attribute" do

    it "if set, delays action submit" do
      Rails.application.routes.append do
        post '/action_test', to: 'action_test#test', as: 'action_delay_test'
      end
      Rails.application.reload_routes!

      class ExamplePage < Matestack::Ui::Page
        def response
          action action_config do
            button text: "Click me!"
          end
          div id: "timestamp" do
            toggle show_on: "action_submitted_successfully" do
              plain "{{vc.event.data.received_at}}"
            end
          end
        end

        def action_config
          return {
            method: :post,
            path: action_delay_test_path,
            data: {
              foo: DateTime.now.strftime('%Q')
            },
            delay: 1000,
            success: {
              emit: "action_submitted_successfully"
            }
          }
        end
      end

      visit "/example"
      submit_timestamp = DateTime.now.strftime('%Q').to_i
      click_button "Click me!"
      sleep 1.5
      element = page.find("#timestamp")
      receive_timestamp = element.text.to_i
      expect(receive_timestamp - submit_timestamp).to be > 1000
    end

  end

end
