require_relative "../../support/utils"
require_relative "../../support/test_controller"
include Utils

describe "Action Component", type: :feature, js: true do
  before :each do
    module Example
    end

    class ActionTestController < TestController
      def test
        render json: {}, status: 200
      end
    end

    allow_any_instance_of(ActionTestController).to receive(:expect_params)
  end

  it "Example 1 - Async request with payload" do
    Rails.application.routes.append do
      post '/action_test', to: 'action_test#test', as: 'action_test' unless path_exists?(:action_test_path)
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page
      def response
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: action_test_path(foo: 'bar')
        }
      end
    end

    visit "/example"
    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:foo => "bar"))
    click_button "Click me!"
  end

  it "Example 2 - Async request with URL param" do
    Rails.application.routes.append do
      post '/action_test/:id', to: 'action_test#test', as: 'action_test_with_url_param' unless path_exists?(:action_test_with_url_param_path)
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page
      def response
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: action_test_with_url_param_path(id: 42),
        }
      end
    end

    visit "/example"
    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:id => "42"))
    click_button "Click me!"
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
        post '/success_action_test', to: 'action_test#success_test', as: 'success_action_test' unless path_exists?(:success_action_test_path)
        post '/failure_action_test', to: 'action_test#failure_test', as: 'failure_action_action_test' # unless path_exists?(:failure_action_test_path)
      end
      Rails.application.reload_routes!
    end

    it "Example 3 - Async request with success event emit used for rerendering" do
      class ExamplePage < Matestack::Ui::Page
        def response
          action action_config do
            button "Click me!"
          end
          async rerender_on: "my_action_success", id: 'async-page' do
            div id: "my-div" do
              plain "#{DateTime.now.strftime('%Q')}"
            end
          end
        end

        def action_config
          return {
            method: :post,
            path: success_action_test_path,
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
          action action_config do
            button "Click me!"
          end
          toggle show_on: "my_action_success", hide_after: 300 do
            plain "{{vc.event.data.message}}"
          end
        end

        def action_config
          return {
            method: :post,
            path: success_action_test_path,
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
          action action_config do
            button "Click me!"
          end
          toggle show_on: "my_action_success", hide_after: 300 do
            plain "{{vc.event.data.message}}"
          end
          toggle show_on: "my_action_failure", hide_after: 300 do
            plain "{{vc.event.data.message}}"
          end
        end

        def action_config
          return {
            method: :post,
            path: failure_action_action_test_path,
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

    it "Example 6 - Async request with success/failure event used for transition" do
      class Example::App < Matestack::Ui::App
        def response
          html do
            head do
              unescape csrf_meta_tags
              unescape Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag(:application)
            end
            body do
              matestack do
                h1 'App'
                yield
                toggle show_on: "my_action_success", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
                toggle show_on: "my_action_failure", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
              end
            end
          end
        end
      end

      module Example::Pages
      end

      class Example::Pages::ExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 1"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: success_action_test_path,
            success: {
              emit: "my_action_success",
              transition: {
                path: action_test_page2_path(id: 42),
              }
            }
          }
        end
      end

      class Example::Pages::SecondExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 2"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: failure_action_action_test_path,
            failure: {
              emit: "my_action_failure",
              transition: {
                path: action_test_page1_path
              }
            }
          }
        end
      end

      class ExampleAppPagesController < ExampleController
        include Matestack::Ui::Core::Helper
        matestack_app Example::App

        def page1
          render(Example::Pages::ExamplePage)
        end

        def page2
          render(Example::Pages::SecondExamplePage)
        end
      end

      Rails.application.routes.append do
        scope :action_test do
          get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1' unless path_exists?(:action_test_page1_path)
          get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2' unless path_exists?(:action_test_page2_path)
        end
      end
      Rails.application.reload_routes!

      visit "action_test/page1"
      expect(page).to have_content("This is Page 1")
      expect(page).not_to have_content("This is Page 2")
      click_button "Click me!"
      expect(page).to have_content("server says: good job!")
      expect(page).not_to have_content("This is Page 1")
      expect(page).to have_content("This is Page 2")

      click_button "Click me!"
      expect(page).to have_content("server says: something went wrong!")
      expect(page).not_to have_content("This is Page 2")
      expect(page).to have_content("This is Page 1")
    end

    it "Example 6.1 - Async request with success/failure event used for redirect" do
      class Example::App < Matestack::Ui::App
        def response
          html do
            head do
              unescape csrf_meta_tags
              unescape Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag(:application)
            end
            body do
              matestack do
                h1 'App'
                yield
                toggle show_on: "my_action_success", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
                toggle show_on: "my_action_failure", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
              end
            end
          end
        end
      end

      module Example::Pages
      end

      class Example::Pages::ExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 1"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: success_action_test_path,
            success: {
              emit: "my_action_success",
              redirect: {
                path: action_test_page2_path(id: 42),
              }
            }
          }
        end
      end

      class Example::Pages::SecondExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 2"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: failure_action_action_test_path,
            failure: {
              emit: "my_action_failure",
              redirect: {
                path: action_test_page1_path
              }
            }
          }
        end
      end

      class ExampleAppPagesController < ExampleController
        include Matestack::Ui::Core::Helper
        matestack_app Example::App

        def page1
          render(Example::Pages::ExamplePage)
        end

        def page2
          render(Example::Pages::SecondExamplePage)
        end
      end

      Rails.application.routes.append do
        scope :action_test do
          get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1' unless path_exists?(:action_test_page1_path)
          get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2' unless path_exists?(:action_test_page2_path)
        end
      end
      Rails.application.reload_routes!

      visit "action_test/page1"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 1")
      expect(page).not_to have_content("This is Page 2")

      click_button "Click me!"
      expect(page).not_to have_selector("body.not-reloaded")
      expect(page).not_to have_content("server says: good job!")
      expect(page).not_to have_content("This is Page 1")
      expect(page).to have_content("This is Page 2")
      page.evaluate_script('document.body.classList.add("not-reloaded")')

      click_button "Click me!"
      expect(page).not_to have_selector("body.not-reloaded")
      expect(page).not_to have_content("server says: something went wrong!")
      expect(page).not_to have_content("This is Page 2")
      expect(page).to have_content("This is Page 1")
    end

    it "Example 6.2 - Async request with success/failure event used for redirect determined by server" do
      class ActionTestController < TestController
        def success_test_with_redirect
          render json: { redirect_to:  action_test_page2_path(id: 42) }, status: 200
        end

        def failure_test_with_redirect
          render json: { redirect_to:  action_test_page1_path }, status: 400
        end
      end

      Rails.application.routes.append do
        post '/success_action_test_with_redirect', to: 'action_test#success_test_with_redirect', as: 'success_action_test_with_redirect' unless path_exists?(:success_action_test_with_redirect_path)
        post '/failure_action_test_with_redirect', to: 'action_test#failure_test_with_redirect', as: 'failure_action_test_with_redirect' unless path_exists?(:failure_action_test_with_redirect_path)
      end
      Rails.application.reload_routes!

      class Example::App < Matestack::Ui::App
        def response
          html do
            head do
              unescape csrf_meta_tags
              unescape Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag(:application)
            end
            body do
              matestack do
                h1 'App'
                yield
                toggle show_on: "my_action_success", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
                toggle show_on: "my_action_failure", hide_after: 300 do
                  plain "{{vc.event.data.message}}"
                end
              end
            end
          end
        end
      end

      module Example::Pages
      end

      class Example::Pages::ExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 1"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: success_action_test_with_redirect_path,
            success: {
              emit: "my_action_success",
              redirect: {
                follow_response: true
              }
            }
          }
        end
      end

      class Example::Pages::SecondExamplePage < Matestack::Ui::Page
        def response
          h2 "This is Page 2"
          action action_config do
            button "Click me!"
          end
        end

        def action_config
          return {
            method: :post,
            path: failure_action_test_with_redirect_path,
            failure: {
              emit: "my_action_failure",
              redirect: {
                follow_response: true
              }
            }
          }
        end
      end

      class ExampleAppPagesController < ExampleController
        include Matestack::Ui::Core::Helper
        matestack_app Example::App

        def page1
          render(Example::Pages::ExamplePage)
        end

        def page2
          render(Example::Pages::SecondExamplePage)
        end
      end

      Rails.application.routes.append do
        scope :action_test do
          get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1' unless path_exists?(:action_test_page1_path)
          get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2' unless path_exists?(:action_test_page2_path)
        end
      end
      Rails.application.reload_routes!

      visit "action_test/page1"
      page.evaluate_script('document.body.classList.add("not-reloaded")')
      expect(page).to have_selector("body.not-reloaded")
      expect(page).to have_content("This is Page 1")
      expect(page).not_to have_content("This is Page 2")

      click_button "Click me!"
      expect(page).not_to have_selector("body.not-reloaded")
      expect(page).not_to have_content("server says: good job!")
      expect(page).not_to have_content("This is Page 1")
      expect(page).to have_content("This is Page 2")
      page.evaluate_script('document.body.classList.add("not-reloaded")')

      click_button "Click me!"
      expect(page).not_to have_selector("body.not-reloaded")
      expect(page).not_to have_content("server says: something went wrong!")
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
        delete '/action_test', to: 'action_test#destroy', as: 'action_destroy_test' unless path_exists?(:action_destroy_test_path)
      end
      Rails.application.reload_routes!

      class ExamplePage < Matestack::Ui::Page
        def response
          action action_config do
            button "Click me!"
          end
          toggle show_on: "my_action_success", hide_after: 300 do
            plain "Well done!"
          end
        end

        def action_config
          return {
            method: :delete,
            path: action_destroy_test_path,
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
      delete '/action_test', to: 'action_test#destroy', as: 'action_destroy_default_text_test' unless path_exists?(:action_destroy_default_text_test_path)
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page
      def response
        action action_config do
          button "Click me!"
        end
        toggle show_on: "my_action_success", hide_after: 300 do
          plain "Well done!"
        end
      end

      def action_config
        return {
          method: :delete,
          path: action_destroy_default_text_test_path,
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
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        {
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
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: '/action_test/42'
        }
      end
    end

    visit "/example"
    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:id => "42"))
    click_button "Click me!"
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
  #     def response
  #       action action_config do
  #         button "Click me!"
  #       end
  #     end
  #
  #     def action_config
  #       return {
  #         method: :post,
  #         action_path: nil
  #       }
  #     end
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
      post '/success_action_test', to: 'action_test#success_test', as: 'success_action_test_string' unless path_exists?(:success_action_test_string_path)
      scope :action_test do
        get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1_string' unless path_exists?(:action_test_page1_string_path)
        get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2_string' unless path_exists?(:action_test_page2_string_path)
      end
    end
    Rails.application.reload_routes!

    # class Example::App < Matestack::Ui::App
    #   def response
    #     h1 "My Example App Layout"
    #     main do
    #       page_content
    #     end
    #   end
    # end

    class ExampleAppPagesController < ExampleController
      include Matestack::Ui::Core::Helper
      matestack_app App

      def page1
        render(Example::Pages::ExamplePage)
      end

      def page2
        render(Example::Pages::SecondExamplePage)
      end
    end

    module Example::Pages
    end

    class Example::Pages::ExamplePage < Matestack::Ui::Page
      def response
        h2 "This is Page 1"
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: success_action_test_string_path,
          success: {
            emit: "my_action_success",
            transition: {
              path: 'page2/42'
            }
          }
        }
      end
    end

    class Example::Pages::SecondExamplePage < Matestack::Ui::Page
      def response
        h2 "This is Page 2"
        paragraph 'You made it!'
      end
    end

    visit "action_test/page1"
    expect(page).to have_content("This is Page 1")
    expect(page).not_to have_content("This is Page 2")

    click_button "Click me!"
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
  #     def response
  #       action action_config do
  #         button "Click me!"
  #       end
  #     end
  #
  #     def action_config
  #       return {
  #         method: :post,
  #         action_path: nil
  #       }
  #     end
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
    module FollowResponseExample
    end

    module FollowResponseExample::Pages
    end

    class FollowResponseExample::Pages::ExamplePage < Matestack::Ui::Page
      def response
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: test_models_path,
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

    class FollowResponseExample::Pages::TestModelPage < Matestack::Ui::Page
      optional :test_model
      def response
        h1 ctx.test_model.title
        plain "This page has been loaded via redirect_to and follow_response."
      end
    end

    class TestModelsController < ExampleController
      include Matestack::Ui::Core::Helper
      matestack_app App

      def index
        render FollowResponseExample::Pages::ExamplePage
      end

      def create
        @test_model = TestModel.create title: params[:title]
        render json: {
          transition_to: test_model_path(id: @test_model.id)
        }, status: :ok
      end

      def show
        @test_model = TestModel.find params[:id]
        render FollowResponseExample::Pages::TestModelPage, test_model: @test_model
      end
    end

    Rails.application.routes.append do
      resources :test_models unless path_exists?(:test_models_path)
    end
    Rails.application.reload_routes!

    visit "/test_models"
    click_button "Click me!"
    expect(page).not_to have_text "Click me"
    expect(page).to have_text "A title for my new test object"
    expect(page).to have_text "This page has been loaded via redirect_to and follow_response."
  end

  specify "follow_response option makes a transition follow controllers' redirect_to" do
    class TestModelsController < ExampleController
      include Matestack::Ui::Core::Helper
      matestack_app App

      def index
        render FollowResponseExample::Pages::ExamplePage
      end

      def create
        @test_model = TestModel.create title: params[:title]
        redirect_to test_model_path(id: @test_model.id)
      end

      def show
        @test_model = TestModel.find params[:id]
        render FollowResponseExample::Pages::TestModelPage, test_model: @test_model
      end
    end

    Rails.application.routes.append do
      resources :test_models unless path_exists?(:test_models_path)
    end
    Rails.application.reload_routes!

    module FollowResponseExample
    end

    module FollowResponseExample::Pages
    end

    class FollowResponseExample::Pages::ExamplePage < Matestack::Ui::Page
      def response
        action action_config do
          button "Click me!"
        end
      end

      def action_config
        return {
          method: :post,
          path: test_models_path,
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

    class FollowResponseExample::Pages::TestModelPage < Matestack::Ui::Page
      optional :test_model
      def response
        h1 ctx.test_model.title
        plain "This page has been loaded via redirect_to and follow_response."
      end
    end

    visit "/test_models"
    click_button "Click me!"
    expect(page).to have_no_text "Click me"
    expect(page).to have_text "A title for my new test object"
    expect(page).to have_text "This page has been loaded via redirect_to and follow_response."
  end

end
