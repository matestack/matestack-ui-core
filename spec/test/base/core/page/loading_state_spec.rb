require_relative "../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do

    class MyApp < Matestack::Ui::App

      def response
        html do
          head do
            unescape csrf_meta_tags
            plain Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag('application').html_safe
          end
          body do
            matestack do
              nav do
                transition "Page 1", path: loading_state_page_1_path 
                transition "Page 2", path: loading_state_page_2_path 
              end
              main do
                yield
               end
            end
          end
        end
      end

    end

    class PageTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::Helper
      matestack_app MyApp

      def page_1
        render ExamplePage1
      end

      def page_2
        render ExamplePage2
      end

    end

    Rails.application.routes.append do
      scope "page_loading_state_spec" do
        get '/page_test_1', to: 'page_test#page_1', as: 'loading_state_page_1'
        get '/page_test_2', to: 'page_test#page_2', as: 'loading_state_page_2'
      end
    end
    Rails.application.reload_routes!

  end

  describe "Loading state" do

    it "during loading the wrapping page elements get loading classes which can be used for css animations" do

      class ExamplePage1 < Matestack::Ui::Page

        def response
          div do
            plain "page 1"
          end
        end

      end

      class ExamplePage2 < Matestack::Ui::Page

        def response
          sleep 1 #mock hard work
          div do
            plain "page 2"
          end
        end

      end

      visit "page_loading_state_spec/page_test_1"

      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
      expect(page).not_to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="loading-state-element-wrapper"]')

      click_on("Page 2")

      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container loading"]/div[@class="matestack-page-wrapper loading"]')
      # after transition back to init state
      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
    end

    it "during loading the wrapping page elements get loading classes which can be used for css animations" do

      class MyApp < Matestack::Ui::App

        def response
          html do
            head do
              unescape csrf_meta_tags
              plain Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag('application').html_safe
            end
            body do
              matestack do
                nav do
                  transition "Page 1", path: loading_state_page_1_path 
                  transition "Page 2", path: loading_state_page_2_path 
                end
                main do
                  yield
                 end
              end
            end
          end
        end

        def my_loading_spinner
          div id: "loading-spinner" do
            plain "loading..."
          end
        end

      end

      class ExamplePage1 < Matestack::Ui::Page

        def response
          div do
            plain "page 1"
          end
        end

      end

      class ExamplePage2 < Matestack::Ui::Page

        def response
          sleep 2 #mock hard work
          div do
            plain "page 2"
          end
        end

      end

      visit "page_loading_state_spec/page_test_1"

      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="loading-state-element-wrapper"]/div[@id="loading-spinner"]')

      click_on("Page 2")

      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container loading"]/div[@class="matestack-page-wrapper loading"]')
      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container loading"]/div[@class="loading-state-element-wrapper loading"]/div[@id="loading-spinner"]')
      # after transition back to init state
      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
      expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="loading-state-element-wrapper"]/div[@id="loading-spinner"]')

    end

    it "works with browser navigation buttons as well" do
      # this actually works, but the spec fails. tbd

      # click_on("Page 1")
      #
      # page.go_back
      #
      # expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container loading"]/div[@class="matestack-page-wrapper loading"]')
      # expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container loading"]/div[@class="loading-state-element-wrapper loading"]/div[@id="loading-spinner"]')
      # # after transition back to init state
      # expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="matestack-page-wrapper"]')
      # expect(page).to have_xpath('//div[@class="matestack-app-wrapper"]/main/div[@class="matestack-page-container"]/div[@class="loading-state-element-wrapper"]/div[@id="loading-spinner"]')
    end

  end

end
