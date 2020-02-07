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

describe "Action Component", type: :feature, js: true do

  before :each do

    class ActionTestController < TestController

      def test
        render json: {}, status: 200
      end

    end

    allow_any_instance_of(ActionTestController).to receive(:expect_params)

  end

  it "Example 1 - Async request with payload" do

    Rails.application.routes.append do
      post '/action_test', to: 'action_test#test', as: 'action_test'
    end
    Rails.application.reload_routes!


    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :action_test_path,
          data: {
            foo: "bar"
          }
        }
      end

    end

    visit "/example"

    click_button "Click me!"

    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:foo => "bar"))

  end

  it "Example 2 - Async request with URL param" do

    Rails.application.routes.append do
      post '/action_test/:id', to: 'action_test#test', as: 'action_test_with_url_param'
    end
    Rails.application.reload_routes!


    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :action_test_with_url_param_path,
          params: {
            id: 42
          }
        }
      end

    end

    visit "/example"

    click_button "Click me!"

    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:id => "42"))

  end

  describe "Success/Failure Behavior" do

    before :all do
      class ActionTestController < TestController

        def success_test
          render json: { message: "server says: good job!" }, status: 200
        end

        def failure_test
          render json: { message: "server says: something went wrong!" }, status: 400
        end

      end

      Rails.application.routes.append do
        post '/success_action_test', to: 'action_test#success_test', as: 'success_action_test'
        post '/failure_action_test', to: 'action_test#failure_test', as: 'failure_action_test'
      end
      Rails.application.reload_routes!
    end

    it "Example 3 - Async request with success event emit used for rerendering" do

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            action action_config do
              button text: "Click me!"
            end
            async rerender_on: "my_action_success" do
              div id: "my-div" do
                plain "#{DateTime.now.strftime('%Q')}"
              end
            end
          }
        end

        def action_config
          return {
            method: :post,
            path: :success_action_test_path,
            success: {
              emit: "my_action_success"
            }
          }
        end

      end

      visit "/example"

      element = page.find("#my-div")
      before_content = element.text

      click_button "Click me!"

      sleep 0.3

      element = page.find("#my-div")
      after_content = element.text

      expect(before_content).not_to eq(after_content)

    end

    it "Example 4 - Async request with success event emit used for notification" do

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            action action_config do
              button text: "Click me!"
            end
            async show_on: "my_action_success", hide_after: 300 do
              plain "{{event.data.message}}"
            end
          }
        end

        def action_config
          return {
            method: :post,
            path: :success_action_test_path,
            success: {
              emit: "my_action_success"
            }
          }
        end

      end

      visit "/example"

      expect(page).not_to have_content("server says: good job!")

      click_button "Click me!"

      expect(page).to have_content("server says: good job!")
      sleep 0.3
      expect(page).not_to have_content("server says: good job!")

    end

    it "Example 5 - Async request with failure event emit used for notification" do

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            action action_config do
              button text: "Click me!"
            end
            async show_on: "my_action_success", hide_after: 300 do
              plain "{{event.data.message}}"
            end
            async show_on: "my_action_failure", hide_after: 300 do
              plain "{{event.data.message}}"
            end
          }
        end

        def action_config
          return {
            method: :post,
            path: :failure_action_test_path,
            success: {
              emit: "my_action_success"
            },
            failure: {
              emit: "my_action_failure"
            }
          }
        end

      end

      visit "/example"

      expect(page).not_to have_content("server says: good job!")
      expect(page).not_to have_content("server says: something went wrong!")

      click_button "Click me!"

      expect(page).not_to have_content("server says: good job!")
      expect(page).to have_content("server says: something went wrong!")
      sleep 0.3
      expect(page).not_to have_content("server says: good job!")
      expect(page).not_to have_content("server says: something went wrong!")

    end

    it "Example 6 - Async request with success event emit used for transition" do
      class Apps::ExampleApp < Matestack::Ui::App

        def response
          components {
            heading size: 1, text: "My Example App Layout"
            main do
              page_content
            end
            async show_on: "my_action_success", hide_after: 300 do
              plain "{{event.data.message}}"
            end
            async show_on: "my_action_failure", hide_after: 300 do
              plain "{{event.data.message}}"
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
            action action_config do
              button text: "Click me!"
            end
          }
        end

        def action_config
          return {
            method: :post,
            path: :success_action_test_path,
            success: {
              emit: "my_action_success",
              transition: {
                path: :action_test_page2_path,
                params: { id: 42 }
              }
            }
          }
        end

      end

      class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

        def response
          components {
            heading size: 2, text: "This is Page 2"
            action action_config do
              button text: "Click me!"
            end
          }
        end

        def action_config
          return {
            method: :post,
            path: :failure_action_test_path,
            failure: {
              emit: "my_action_failure",
              transition: {
                path: :action_test_page1_path
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
        scope :action_test do
          get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1'
          get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2'
        end
      end
      Rails.application.reload_routes!

      visit "action_test/page1"

      expect(page).to have_content("My Example App Layout")
      expect(page).to have_content("This is Page 1")
      expect(page).not_to have_content("This is Page 2")

      click_button "Click me!"

      expect(page).to have_content("My Example App Layout")
      expect(page).to have_content("server says: good job!")

      expect(page).not_to have_content("This is Page 1")
      expect(page).to have_content("This is Page 2")

      click_button "Click me!"

      expect(page).to have_content("My Example App Layout")
      expect(page).to have_content("server says: something went wrong!")

      expect(page).not_to have_content("This is Page 2")
      expect(page).to have_content("This is Page 1")

    end

    specify "Async delete request with confirm option" do

      class ActionTestController < TestController
        def destroy
          render json: {}, status: 200
        end
      end

      Rails.application.routes.append do
        delete '/action_test', to: 'action_test#destroy', as: 'action_destroy_test'
      end
      Rails.application.reload_routes!

      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            action action_config do
              button text: "Click me!"
            end
            async show_on: "my_action_success", hide_after: 300 do
              plain "Well done!"
            end
          }
        end

        def action_config
          return {
            method: :delete,
            path: :action_destroy_test_path,
            data: {
              foo: "bar"
            },
            confirm: {
              text: "Are you sure?"
            },
            success: {
              emit: "my_action_success"
            }
          }
        end

      end

      visit "/example"

      # https://stackoverflow.com/a/34888404/2066546
      # https://github.com/teamcapybara/capybara#modals
      dismiss_confirm do
        click_button "Click me!"
      end

      expect(page).to have_no_text "Well done!"

      accept_confirm do
        click_button "Click me!"
      end

      expect(page).to have_text "Well done!"
    end

  end

  it 'does not require a confirm text option' do
    # When no confirm text is given, the default "Are you sure?" will be used.

    class ActionTestController < TestController
      def destroy
        render json: {}, status: 200
      end
    end

    Rails.application.routes.append do
      delete '/action_test', to: 'action_test#destroy', as: 'action_destroy_default_text_test'
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          action action_config do
            button text: "Click me!"
          end
          async show_on: "my_action_success", hide_after: 300 do
            plain "Well done!"
          end
        }
      end

      def action_config
        return {
          method: :delete,
          path: :action_destroy_default_text_test_path,
          data: {
            foo: "bar"
          },
          confirm: true,
          success: {
            emit: "my_action_success"
          }
        }
      end

    end

    visit "/example"

    dismiss_confirm do
      click_button "Click me!"
    end

    expect(page).to have_no_text "Well done!"

    accept_confirm do
      click_button "Click me!"
    end

    expect(page).to have_text "Well done!"
  end

  it 'accepts class and id attributes and returns them as the corresponding HTML attributes' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          id: 'action-id',
          class: 'action-class'
        }
      end

    end

    visit "/example"

    expect(page).to have_css('a#action-id.action-class')

  end

  it 'action_path: passing path as a string (not recommended)' do

    Rails.application.routes.append do
      post '/action_test/:id', to: 'action_test#test'
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: '/action_test/42'
        }
      end

    end

    visit "/example"

    click_button "Click me!"

    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:id => "42"))

  end

  # not working right now
  # it 'action_path: passing no path and expecting an error' do
  #
  #   Rails.application.routes.append do
  #     post '/action_test/:id', to: 'action_test#test', as: 'action_test_fail_route'
  #   end
  #   Rails.application.reload_routes!
  #
  #   class ExamplePage < Matestack::Ui::Page
  #
  #     def response
  #       components {
  #         action action_config do
  #           button text: "Click me!"
  #         end
  #       }
  #     end
  #
  #     def action_config
  #       return {
  #         method: :post,
  #         action_path: nil
  #       }
  #     end
  #
  #   end
  #
  #   visit "/example"
  #
  #   click_button "Click me!"
  #
  #   # this is somewhat not happening
  #   expect(page).to have_content("Action path not found")
  #
  # end

  it 'transition_path: passing path as a string (not recommended)' do

    class ActionTestController < TestController
      def success_test
        render json: { message: "server says: good job!" }, status: 200
      end
    end

    Rails.application.routes.append do
      post '/success_action_test', to: 'action_test#success_test', as: 'success_action_test_string'
      scope :action_test do
        get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1_string'
        get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2_string'
      end
    end
    Rails.application.reload_routes!

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def page1
        responder_for(Pages::ExampleApp::ExamplePage)
      end

      def page2
        responder_for(Pages::ExampleApp::SecondExamplePage)
      end

    end

    class Apps::ExampleApp < Matestack::Ui::App

      def response
        components {
          heading size: 1, text: "My Example App Layout"
          main do
            page_content
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
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :success_action_test_string_path,
          success: {
            emit: "my_action_success",
            transition: {
              path: 'page2/42'
            }
          }
        }
      end

    end

    class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

      def response
        components {
          heading size: 2, text: "This is Page 2"
          paragraph text: 'You made it!'
        }
      end

    end

    visit "action_test/page1"

    expect(page).to have_content("My Example App Layout")
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")

    click_button "Click me!"

    expect(page).to have_content("My Example App Layout")

    expect(page).not_to have_content("This is Page 1")
    expect(page).to have_content("This is Page 2")
    expect(page).to have_content("You made it!")

  end

  # not working right now
  # it 'transition_path: passing no path and expecting an error' do
  #
  #   Rails.application.routes.append do
  #     post '/action_test/:id', to: 'action_test#test', as: 'action_test_fail_route'
  #   end
  #   Rails.application.reload_routes!
  #
  #   class ExamplePage < Matestack::Ui::Page
  #
  #     def response
  #       components {
  #         action action_config do
  #           button text: "Click me!"
  #         end
  #       }
  #     end
  #
  #     def action_config
  #       return {
  #         method: :post,
  #         action_path: nil
  #       }
  #     end
  #
  #   end
  #
  #   visit "/example"
  #
  #   click_button "Click me!"
  #
  #   # this is somewhat not happening
  #   expect(page).to have_content("Action path not found")
  #
  # end

  specify "follow_response option makes a transition follow controllers' transition_to" do

    class TestModelsController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def index
        responder_for Pages::FollowResponseExampleApp::ExamplePage
      end

      def create
        @test_model = TestModel.create title: params[:title]
        render json: {
          transition_to: test_model_path(id: @test_model.id)
        }, status: :ok
      end

      def show
        @test_model = TestModel.find params[:id]
        responder_for Pages::FollowResponseExampleApp::TestModelPage
      end
    end

    Rails.application.routes.append do
      resources :test_models
    end
    Rails.application.reload_routes!

    class Apps::FollowResponseExampleApp < Matestack::Ui::App
      def response
        components {
          heading size: 1, text: "My Example App Layout"
          main do
            page_content
          end
        }
      end
    end

    module Pages::FollowResponseExampleApp
    end

    class Pages::FollowResponseExampleApp::ExamplePage < Matestack::Ui::Page
      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :test_models_path,
          data: {
            title: "A title for my new test object"
          },
          success: {
            transition: {
              follow_response: true
            }
          }
        }
      end

    end

    class Pages::FollowResponseExampleApp::TestModelPage < Matestack::Ui::Page
      def response
        components {
          heading text: @test_model.title, size: 1
          plain "This page has been loaded via redirect_to and follow_response."
        }
      end
    end

    visit "/test_models"

    click_button "Click me!"

    expect(page).to have_no_text "Click me"
    expect(page).to have_text "A title for my new test object"
    expect(page).to have_text "This page has been loaded via redirect_to and follow_response."

  end

  specify "follow_response option makes a transition follow controllers' redirect_to" do

    class TestModelsController < ExampleController
      include Matestack::Ui::Core::ApplicationHelper

      def index
        responder_for Pages::FollowResponseExampleApp::ExamplePage
      end

      def create
        @test_model = TestModel.create title: params[:title]
        redirect_to test_model_path(id: @test_model.id)
      end

      def show
        @test_model = TestModel.find params[:id]
        responder_for Pages::FollowResponseExampleApp::TestModelPage
      end
    end

    Rails.application.routes.append do
      resources :test_models
    end
    Rails.application.reload_routes!

    class Apps::FollowResponseExampleApp < Matestack::Ui::App
      def response
        components {
          heading size: 1, text: "My Example App Layout"
          main do
            page_content
          end
        }
      end
    end

    module Pages::FollowResponseExampleApp
    end

    class Pages::FollowResponseExampleApp::ExamplePage < Matestack::Ui::Page
      def response
        components {
          action action_config do
            button text: "Click me!"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :test_models_path,
          data: {
            title: "A title for my new test object"
          },
          success: {
            transition: {
              follow_response: true
            }
          }
        }
      end

    end

    class Pages::FollowResponseExampleApp::TestModelPage < Matestack::Ui::Page
      def response
        components {
          heading text: @test_model.title, size: 1
          plain "This page has been loaded via redirect_to and follow_response."
        }
      end
    end

    visit "/test_models"

    click_button "Click me!"

    expect(page).to have_no_text "Click me"
    expect(page).to have_text "A title for my new test object"
    expect(page).to have_text "This page has been loaded via redirect_to and follow_response."

  end

end
