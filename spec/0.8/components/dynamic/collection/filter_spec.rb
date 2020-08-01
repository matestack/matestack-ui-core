require_relative "../../../../support/utils"
include Utils

describe "Collection Component", type: :feature, js: true do

  describe 'filter' do

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

    it "Example 1 - Filterable collection" do
      class ExamplePage < Matestack::Ui::Page
        include Matestack::Ui::Core::Collection::Helper

        def prepare
          my_collection_id = "my-first-collection"
          current_filter = get_collection_filter(my_collection_id)
          my_base_query = TestModel.all
          my_filtered_query = my_base_query.where("title LIKE ?", "%#{current_filter[:title]}%")
          my_filtered_query = my_base_query.where("title LIKE ?", "%#{current_filter[:ends_with]}") unless current_filter[:ends_with].nil?
          my_filtered_query = my_filtered_query.where(description: current_filter[:description]) unless current_filter[:description].nil?
          @my_collection = set_collection({
            id: my_collection_id,
            data: my_filtered_query
          })
        end

        def response
          heading size: 2, text: "My Collection"
          filter
          content
        end

        def filter
          collection_filter @my_collection.config do
            collection_filter_select id: "my-title-filter-select-ends-with", key: :ends_with, type: :dropdown, options: (1..10).to_a, placeholder: "Ends with"
            collection_filter_input id: "my-title-filter-input", key: :title, type: :text, placeholder: "Filter by title"
            collection_filter_input id: "my-description-filter-input", key: :description, type: :text, placeholder: "Filter by description"
            collection_filter_submit do
              button text: "filter"
            end
            collection_filter_reset do
              button text: "reset"
            end
          end
        end

        def content
          async rerender_on: "my-first-collection-update", id: "some-unique-id" do
            collection_content @my_collection.config do
              ul do
                @my_collection.data.each do |dummy|
                  li do
                    plain dummy.title
                    plain " "
                    plain dummy.description
                  end
                end
              end
            end
          end
        end
      end

      visit "/example"
      
      # display whole range
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-11")

      fill_in "my-title-filter-input", with: "some-title-2"
      click_button "filter"
      # display only matching result
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-11")

      fill_in "my-title-filter-input", with: "some-title-3"
      find('#my-title-filter-input').native.send_keys(:return)
      # display only matching result on enter
      expect(page).not_to have_content("some-title-2")
      expect(page).to have_content("some-title-3")

      click_button "reset"
      # display whole range again
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-11")

      fill_in "my-description-filter-input", with: "some-description-2"
      click_button "filter"
      # display only matching result
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")

      fill_in "my-title-filter-input", with: "some-title-2"
      fill_in "my-description-filter-input", with: "some-description-1"
      click_button "filter"
      # display nothing because title AND description input can't be matched together
      expect(page).not_to have_content("some-title-1")
      expect(page).not_to have_content("some-title-2")

      click_button "reset"
      # display whole range again
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-11")

      select "2", from: "my-title-filter-select-ends-with"
      click_button "filter"
      # display only matching result
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")

      select "1", from: "my-title-filter-select-ends-with"
      click_button "filter"
      expect(page).to have_content("some-title-1")
      expect(page).not_to have_content("some-title-2")

      click_button "reset"
      # test persistent state
      fill_in "my-title-filter-input", with: "some-title-2"
      fill_in "my-description-filter-input", with: "some-description-2"
      click_button "filter"
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")

      page.driver.browser.navigate.refresh
      expect(page.find("#my-title-filter-input").value).to eq("some-title-2")
      expect(page.find("#my-description-filter-input").value).to eq("some-description-2")
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
    end

  end

end
