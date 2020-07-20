require_relative "../../../../support/utils"
include Utils

describe "Collection Component", type: :feature, js: true do

  describe 'pagination' do

    before :each do
      TestModel.destroy_all
      TestModel.create([
        { title: "some-title-1", description: "some-description-1" },
        { title: "some-title-2", description: "some-description-2" },
        { title: "some-title-3", description: "some-description-3" },
        { title: "some-title-4", description: "some-description-4" },
        { title: "some-title-5", description: "some-description-5" },
        { title: "some-title-6", description: "some-description-6" },
        { title: "some-title-7", description: "some-description-7" },
        { title: "some-title-8", description: "some-description-8" },
        { title: "some-title-9", description: "some-description-9" },
        { title: "some-title-10", description: "some-description-10" },
        { title: "some-title-11", description: "some-description-11"}
      ])
    end

    it "Example 2 - Paginated collection" do
      class ExamplePage < Matestack::Ui::Page
        include Matestack::Ui::Core::Collection::Helper

        def prepare
          my_collection_id = "my-first-collection"
          my_base_query = TestModel.all
          @my_collection = set_collection({
            id: my_collection_id,
            data: my_base_query,
            base_count: my_base_query.count,
            init_limit: 5
          })
        end

        def response
          heading size: 2, text: "My Collection"
          content
        end

        def content
          async rerender_on: "my-first-collection-update" do
            collection_content @my_collection.config do
              ul do
                @my_collection.paginated_data.each do |dummy|
                  li do
                    plain dummy.title
                    plain " "
                    plain dummy.description
                  end
                end
              end
              paginator
            end
          end
        end

        def paginator
          plain "showing #{@my_collection.from}"
          plain "to #{@my_collection.to}"
          plain "from total #{@my_collection.base_count}"
          collection_content_previous do
            button text: "previous"
          end
          @my_collection.pages.each do |page|
            collection_content_page_link page: page do
              button text: page
            end
          end
          collection_content_next do
            button text: "next"
          end
        end
      end

      visit "/example"
      # display only 1-5 as we specified init_limit:5
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-5")
      expect(page).not_to have_content("some-title-6")
      expect(page).to have_content("showing 1 to 5 from total 11")
      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).to have_button("2")
      expect(page).to have_button("3")
      expect(page).to have_button("next")

      click_button "next"
      expect(page).not_to have_content("some-title-5")
      expect(page).to have_content("some-title-6")
      expect(page).to have_content("some-title-10")
      expect(page).not_to have_content("some-title-11")
      expect(page).to have_content("showing 6 to 10 from total 11")

      click_button "next"
      expect(page).not_to have_content("some-title-10")
      expect(page).to have_content("some-title-11")
      expect(page).to have_content("showing 11 to 11 from total 11")

      click_button "previous"
      expect(page).not_to have_content("some-title-5")
      expect(page).to have_content("some-title-6")
      expect(page).to have_content("some-title-10")
      expect(page).not_to have_content("some-title-11")
      expect(page).to have_content("showing 6 to 10 from total 11")

      click_button "previous"
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-5")
      expect(page).not_to have_content("some-title-6")
      expect(page).to have_content("showing 1 to 5 from total 11")

      click_button "3"
      expect(page).not_to have_content("some-title-10")
      expect(page).to have_content("some-title-11")
      expect(page).to have_content("showing 11 to 11 from total 11")

      click_button "1"
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-5")
      expect(page).not_to have_content("some-title-6")
      expect(page).to have_content("showing 1 to 5 from total 11")

      click_button "2"
      expect(page).not_to have_content("some-title-5")
      expect(page).to have_content("some-title-6")
      expect(page).to have_content("some-title-10")
      expect(page).not_to have_content("some-title-11")
      expect(page).to have_content("showing 6 to 10 from total 11")

      # test persistent state
      page.driver.browser.navigate.refresh
      expect(page).to have_content("showing 6 to 10 from total 11")
    end

    it "Example 7 - Action enriched, paginated collection" do

      class CollectionTestController < ActionController::Base
        def destroy_test_model
          @test_model = TestModel.find(params[:id])
          @test_model.destroy
          render json: {
            message: "server says: test model destroyed"
          }, status: :ok
        end
      end
  
      Rails.application.routes.append do
        delete '/delete_test_model_2', to: 'collection_test#destroy_test_model', as: 'delete_test_model_2'
      end
      Rails.application.reload_routes!
  
      class ExamplePage < Matestack::Ui::Page
        include Matestack::Ui::Core::HasViewContext
        include Matestack::Ui::Core::Collection::Helper
  
        def prepare
          my_collection_id = "my-first-collection"
          my_base_query = TestModel.all
          @my_collection = set_collection({
            id: my_collection_id,
            data: my_base_query,
            base_count: my_base_query.count,
            init_limit: 5
          })
        end
  
        def response
          heading size: 2, text: "My Collection"
          content
        end
  
        def content
          async rerender_on: "my-first-collection-update" do
            collection_content @my_collection.config do
              ul do
                @my_collection.paginated_data.each do |dummy|
                  li do
                    plain dummy.title
                    plain " "
                    plain dummy.description
                    action my_action_config(dummy.id) do
                      button text: "delete #{dummy.title}"
                    end
                  end
                end
              end
              paginator
            end
          end
        end
  
        def paginator
          plain "showing #{@my_collection.from}"
          plain "to #{@my_collection.to}"
          plain "from total #{@my_collection.base_count}"
  
          collection_content_previous do
            button text: "previous"
          end
  
          @my_collection.pages.each do |page|
            collection_content_page_link page: page do
              button text: page
            end
          end
  
          collection_content_next do
            button text: "next"
          end
        end
  
        def my_action_config id
          {
            method: :delete,
            path: :delete_test_model_2_path,
            params:{
              id: id
            },
            success: {
              emit: "my-first-collection-update"
            }
          }
        end
      end
  
      visit "/example"
      click_button "3"
      expect(page).to have_content("showing 11 to 11 from total 11")
  
      click_button "delete some-title-11"
      expect(page).to have_content("showing 6 to 10 from total 10")
    end

  end

end