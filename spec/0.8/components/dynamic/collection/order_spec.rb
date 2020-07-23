require_relative "../../../../support/utils"
include Utils

describe "Collection Component", type: :feature, js: true do

  describe 'order' do

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

    it "Example 3 - Ordered collection" do
      class ExamplePage < Matestack::Ui::Page
        include Matestack::Ui::Core::Collection::Helper

        def prepare
          my_collection_id = "my-first-collection"
          current_order = get_collection_order(my_collection_id)
          my_base_query = TestModel.all.order(current_order)
          @my_collection = set_collection({
            id: my_collection_id,
            data: my_base_query
          })
        end

        def response
          heading size: 2, text: "My Collection"
          ordering
          content
        end

        def ordering
          collection_order @my_collection.config do
            plain "sort by:"
            collection_order_toggle key: :title do
              button do
                plain "title"
                collection_order_toggle_indicator key: :title, asc: ' asc', desc: ' desc'
              end
            end
          end
        end

        def content
          async rerender_on: "my-first-collection-update" do
            collection_content @my_collection.config do
              ul do
                @my_collection.paginated_data.each do |dummy|
                  li class: "item" do
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
      expect(page).to have_button("title")
      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-11 some-description-11"

      click_button "title"
      sleep 0.2 # otherwise getting stale element error, quick fix
      expect(page).to have_button("title asc")
      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-9 some-description-9"

      click_button "title asc"
      sleep 0.2 # otherwise getting stale element error, quick fix
      expect(page).to have_button("title desc")
      expect(all(".item").first.text).to eq "some-title-9 some-description-9"
      expect(all(".item").last.text).to eq "some-title-1 some-description-1"

      click_button "title desc"
      sleep 0.2 # otherwise getting stale element error, quick fix
      expect(page).to have_button("title")
      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-11 some-description-11"

      # test persistent state
      page.driver.browser.navigate.refresh
      sleep 0.2 # otherwise getting stale element error, quick fix
      expect(page).to have_button("title")
      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-11 some-description-11"
    end
  end
end