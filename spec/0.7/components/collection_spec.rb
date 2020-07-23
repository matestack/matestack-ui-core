require_relative "../../support/utils"
include Utils

describe "Collection Component", type: :feature, js: true do

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
        my_filtered_query = my_filtered_query.where(description: current_filter[:description]) unless current_filter[:description].nil?

        @my_collection = set_collection({
          id: my_collection_id,
          data: my_filtered_query
        })
      end

      def response
        components {
          heading size: 2, text: "My Collection"

          partial :filter
          partial :content
        }
      end

      def filter
        partial {
          collection_filter @my_collection.config do

            collection_filter_input id: "my-title-filter-input", key: :title, type: :text, placeholder: "Filter by title"
            collection_filter_input id: "my-description-filter-input", key: :description, type: :text, placeholder: "Filter by description"
            collection_filter_submit do
              button text: "filter"
            end
            collection_filter_reset do
              button text: "reset"
            end

          end
        }
      end

      def content
        partial {
          async rerender_on: "my-first-collection-update" do
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
        }
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
        components {
          heading size: 2, text: "My Collection"

          partial :content
        }
      end

      def content
        partial {
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
              partial :paginator
            end
          end
        }
      end

      def paginator
        partial {
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
        }
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
        components {
          heading size: 2, text: "My Collection"

          partial :ordering
          partial :content
        }
      end

      def ordering
        partial {
          collection_order @my_collection.config do

            plain "sort by:"
            collection_order_toggle key: :title do
              button do
                plain "title"
                collection_order_toggle_indicator key: :title, asc: ' asc', desc: ' desc'
              end
            end

          end
        }
      end

      def content
        partial {
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
        }
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

  it "Example 4 - Paginated, filtered and ordered collection" do

    class ExamplePage < Matestack::Ui::Page

      include Matestack::Ui::Core::Collection::Helper

      def prepare
        my_collection_id = "my-first-collection"

        current_filter = get_collection_filter(my_collection_id)
        current_order = get_collection_order(my_collection_id)

        my_base_query = TestModel.all.order(current_order)

        my_filtered_query = my_base_query
          .where("title LIKE ?", "%#{current_filter[:title]}%")

        @my_collection = set_collection({
          id: my_collection_id,
          data: my_filtered_query,
          base_count: my_base_query.count,
          filtered_count: my_filtered_query.count,
          init_limit: 2
        })
      end

      def response
        components {
          heading size: 2, text: "My Collection"

          partial :filter
          partial :ordering
          partial :content
        }
      end

      def filter
        partial {
          collection_filter @my_collection.config do

            collection_filter_input id: "my-title-filter-input", key: :title, type: :text, placeholder: "Filter by title"
            collection_filter_submit do
              button text: "filter"
            end
            collection_filter_reset do
              button text: "reset"
            end

          end
        }
      end

      def ordering
        partial {
          collection_order @my_collection.config do

            plain "sort by:"
            collection_order_toggle key: :title do
              button do
                plain "title"
                collection_order_toggle_indicator key: :title, asc: ' asc', desc: ' desc'
              end
            end

          end
        }
      end

      def content
        partial {
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
              partial :paginator
            end
          end
        }
      end

      def paginator
        partial {
          plain "showing #{@my_collection.from}"
          plain "to #{@my_collection.to}"
          plain "of #{@my_collection.filtered_count}"
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
        }
      end

    end

    visit "/example"

    # display only 1-5 as we specified init_limit:5
    expect(page).to have_content("some-title-1")
    expect(page).to have_content("some-title-2")
    expect(page).not_to have_content("some-title-3")

    expect(page).to have_button("previous")
    expect(page).to have_button("1")
    expect(page).to have_button("2")
    expect(page).to have_button("3")
    expect(page).to have_button("4")
    expect(page).to have_button("5")
    expect(page).to have_button("6")
    expect(page).to have_button("next")

    expect(page).to have_content("showing 1 to 2 of 11 from total 11")

    fill_in "my-title-filter-input", with: "some-title-2"

    click_button "filter"

    expect(page).not_to have_content("some-title-1")
    expect(page).to have_content("some-title-2")
    expect(page).not_to have_content("some-title-3")

    expect(page).to have_button("previous")
    expect(page).to have_button("1")
    expect(page).not_to have_button("2")
    expect(page).not_to have_button("3")
    expect(page).not_to have_button("4")
    expect(page).not_to have_button("5")
    expect(page).not_to have_button("6")
    expect(page).to have_button("next")

    expect(page).to have_content("showing 1 to 1 of 1 from total 11")

    fill_in "my-title-filter-input", with: "some-title-1"

    click_button "filter"

    expect(page).to have_content("some-title-1")
    expect(page).to have_content("some-title-10")
    expect(page).not_to have_content("some-title-11")

    expect(page).to have_button("previous")
    expect(page).to have_button("1")
    expect(page).to have_button("2")
    expect(page).not_to have_button("3")
    expect(page).not_to have_button("4")
    expect(page).not_to have_button("5")
    expect(page).not_to have_button("6")
    expect(page).to have_button("next")

    expect(page).to have_content("showing 1 to 2 of 3 from total 11")

    expect(page).to have_button("title")

    expect(all(".item").first.text).to eq "some-title-1 some-description-1"
    expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    expect(page).to have_content("showing 1 to 2 of 3 from total 11")

    click_button "title"
    sleep 0.2 # otherwise getting stale element error, quick fix

    expect(page).to have_button("title asc")

    expect(all(".item").first.text).to eq "some-title-1 some-description-1"
    expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    expect(page).to have_content("showing 1 to 2 of 3 from total 11")

    click_button "title asc"
    sleep 0.2 # otherwise getting stale element error, quick fix

    expect(page).to have_button("title desc")

    expect(all(".item").first.text).to eq "some-title-11 some-description-11"
    expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    expect(page).to have_content("showing 1 to 2 of 3 from total 11")

    click_button "title desc"
    sleep 0.2 # otherwise getting stale element error, quick fix

    expect(page).to have_button("title")

    expect(all(".item").first.text).to eq "some-title-1 some-description-1"
    expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    expect(page).to have_content("showing 1 to 2 of 3 from total 11")

    click_button "reset"
    sleep 0.2 # otherwise getting stale element error, quick fix

    expect(all(".item").first.text).to eq "some-title-1 some-description-1"
    expect(all(".item").last.text).to eq "some-title-2 some-description-2"
    expect(page).to have_content("showing 1 to 2 of 11 from total 11")

    click_button "title"
    sleep 0.2 # otherwise getting stale element error, quick fix

    expect(page).to have_button("title asc")

    expect(all(".item").first.text).to eq "some-title-1 some-description-1"
    expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    expect(page).to have_content("showing 1 to 2 of 11 from total 11")


  end

  it "Example 5 - Multiple paginated, filtered and ordered collection on one page" do

    class ExamplePage < Matestack::Ui::Page

      include Matestack::Ui::Core::Collection::Helper

      def prepare
        my_second_collection_id = "my-second-collection"
        my_first_collection_id = "my-first-collection"

        first_current_filter = get_collection_filter(my_first_collection_id)
        first_current_order = get_collection_order(my_first_collection_id)

        my_first_base_query = TestModel.all.order(first_current_order)

        my_first_filtered_query = my_first_base_query
          .where("title LIKE ?", "%#{first_current_filter[:title]}%")

        @my_first_collection = set_collection({
          id: my_first_collection_id,
          data: my_first_filtered_query,
          base_count: my_first_base_query.count,
          filtered_count: my_first_filtered_query.count,
          init_limit: 2
        })

        my_second_collection_id = "my-second-collection"

        second_current_filter = get_collection_filter(my_second_collection_id)
        second_current_order = get_collection_order(my_second_collection_id)

        my_second_base_query = TestModel.all.order(second_current_order)

        my_second_filtered_query = my_second_base_query
          .where("title LIKE ?", "%#{second_current_filter[:title]}%")

        @my_second_collection = set_collection({
          id: my_second_collection_id,
          data: my_second_filtered_query,
          base_count: my_second_base_query.count,
          filtered_count: my_second_filtered_query.count,
          init_limit: 2
        })
      end

      def response
        components {
          heading size: 2, text: "My Collection"

          partial :first_collection
          partial :second_collection

        }
      end

      def first_collection
        partial {
          div id: "collection-1" do
            partial :filter_1
            partial :ordering_1
            partial :content_1
          end
        }
      end

      def second_collection
        partial {
          div id: "collection-2" do
            partial :filter_2
            partial :ordering_2
            partial :content_2
          end
        }
      end

      def filter_1
        partial {
          collection_filter @my_first_collection.config do

            collection_filter_input id: "my-title-filter-input", key: :title, type: :text, placeholder: "Filter by title"
            collection_filter_submit do
              button text: "filter"
            end
            collection_filter_reset do
              button text: "reset"
            end

          end
        }
      end

      def ordering_1
        partial {
          collection_order @my_first_collection.config do

            plain "sort by:"
            collection_order_toggle key: :title do
              button do
                plain "title"
                collection_order_toggle_indicator key: :title, asc: ' asc', desc: ' desc'
              end
            end

          end
        }
      end

      def content_1
        partial {
          async rerender_on: "my-first-collection-update" do
            collection_content @my_first_collection.config do
              ul do
                @my_first_collection.paginated_data.each do |dummy|
                  li class: "item" do
                    plain dummy.title
                    plain " "
                    plain dummy.description
                  end
                end
              end
              partial :paginator_1
            end
          end
        }
      end

      def paginator_1
        partial {
          plain "showing #{@my_first_collection.from}"
          plain "to #{@my_first_collection.to}"
          plain "of #{@my_first_collection.filtered_count}"
          plain "from total #{@my_first_collection.base_count}"

          collection_content_previous do
            button text: "previous"
          end

          @my_first_collection.pages.each do |page|
            collection_content_page_link page: page do
              button text: page
            end
          end

          collection_content_next do
            button text: "next"
          end
        }
      end

      def filter_2
        partial {
          collection_filter @my_second_collection.config do

            collection_filter_input id: "my-title-filter-input", key: :title, type: :text, placeholder: "Filter by title"
            collection_filter_submit do
              button text: "filter"
            end
            collection_filter_reset do
              button text: "reset"
            end

          end
        }
      end

      def ordering_2
        partial {
          collection_order @my_second_collection.config do

            plain "sort by:"
            collection_order_toggle key: :title do
              button do
                plain "title"
                collection_order_toggle_indicator key: :title, asc: ' asc', desc: ' desc'
              end
            end

          end
        }
      end

      def content_2
        partial {
          async rerender_on: "my-second-collection-update" do
            collection_content @my_second_collection.config do
              ul do
                @my_second_collection.paginated_data.each do |dummy|
                  li class: "item" do
                    plain dummy.title
                    plain " "
                    plain dummy.description
                  end
                end
              end
              partial :paginator_2
            end
          end
        }
      end

      def paginator_2
        partial {
          plain "showing #{@my_second_collection.from}"
          plain "to #{@my_second_collection.to}"
          plain "of #{@my_second_collection.filtered_count}"
          plain "from total #{@my_second_collection.base_count}"

          collection_content_previous do
            button text: "previous"
          end

          @my_second_collection.pages.each do |page|
            collection_content_page_link page: page do
              button text: page
            end
          end

          collection_content_next do
            button text: "next"
          end
        }
      end

    end

    visit "/example"

    within "#collection-1" do
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-3")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).to have_button("2")
      expect(page).to have_button("3")
      expect(page).to have_button("4")
      expect(page).to have_button("5")
      expect(page).to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 2 of 11 from total 11")
    end

    within "#collection-2" do
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-3")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).to have_button("2")
      expect(page).to have_button("3")
      expect(page).to have_button("4")
      expect(page).to have_button("5")
      expect(page).to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 2 of 11 from total 11")
    end

    # filter just within collection 2
    within "#collection-2" do
      fill_in "my-title-filter-input", with: "some-title-2"

      click_button "filter"

      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-3")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).not_to have_button("2")
      expect(page).not_to have_button("3")
      expect(page).not_to have_button("4")
      expect(page).not_to have_button("5")
      expect(page).not_to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 1 of 1 from total 11")
    end

    # collection 1 still the same
    within "#collection-1" do
      expect(page).to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-3")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).to have_button("2")
      expect(page).to have_button("3")
      expect(page).to have_button("4")
      expect(page).to have_button("5")
      expect(page).to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 2 of 11 from total 11")
    end

    # filter also within collection 1
    within "#collection-1" do
      fill_in "my-title-filter-input", with: "some-title-3"

      click_button "filter"

      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-3")
      expect(page).not_to have_content("some-title-2")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).not_to have_button("2")
      expect(page).not_to have_button("3")
      expect(page).not_to have_button("4")
      expect(page).not_to have_button("5")
      expect(page).not_to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 1 of 1 from total 11")
    end

    # reset collection 1 and go to page 3
    within "#collection-1" do
      click_button "reset"
      click_button "3"
      expect(page).to have_content("showing 5 to 6 of 11 from total 11")
    end

    # collection 2 is still the same
    within "#collection-2" do
      expect(page).not_to have_content("some-title-1")
      expect(page).to have_content("some-title-2")
      expect(page).not_to have_content("some-title-3")

      expect(page).to have_button("previous")
      expect(page).to have_button("1")
      expect(page).not_to have_button("2")
      expect(page).not_to have_button("3")
      expect(page).not_to have_button("4")
      expect(page).not_to have_button("5")
      expect(page).not_to have_button("6")
      expect(page).to have_button("next")

      expect(page).to have_content("showing 1 to 1 of 1 from total 11")
    end

    # reset and order just collection 2
    within "#collection-2" do
      click_button "reset"
      sleep 0.2 # otherwise getting stale element error, quick fix
      expect(page).to have_button("title")

      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-2 some-description-2"

      click_button "title"
      sleep 0.2 # otherwise getting stale element error, quick fix

      expect(page).to have_button("title asc")

      expect(all(".item").first.text).to eq "some-title-1 some-description-1"
      expect(all(".item").last.text).to eq "some-title-10 some-description-10"
    end

    # collection 1 is still the same
    within "#collection-1" do
      expect(page).not_to have_button("title asc")
      expect(all(".item").first.text).to eq "some-title-5 some-description-5"
      expect(all(".item").last.text).to eq "some-title-6 some-description-6"
      expect(page).to have_content("showing 5 to 6 of 11 from total 11")
    end

    # test persistent state
    page.driver.browser.navigate.refresh

    # collection 1 is still the same
    within "#collection-1" do
      expect(page).not_to have_button("title asc")
      expect(all(".item").first.text).to eq "some-title-5 some-description-5"
      expect(all(".item").last.text).to eq "some-title-6 some-description-6"
      expect(page).to have_content("showing 5 to 6 of 11 from total 11")
    end

  end

  it "Example 6 - Action enriched collection" do

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
      delete '/delete_test_model', to: 'collection_test#destroy_test_model', as: 'delete_test_model'
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page

      include Matestack::Ui::Core::Collection::Helper

      def prepare
        my_collection_id = "my-first-collection"

        my_base_query = TestModel.all

        @my_collection = set_collection({
          id: my_collection_id,
          data: my_base_query,
        })
      end

      def response
        components {
          heading size: 2, text: "My Collection"

          partial :content
        }
      end

      def content
        partial {
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
            end
          end
        }
      end

      def my_action_config id
        {
          method: :delete,
          path: :delete_test_model_path,
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

    expect(page).to have_content("some-title-3")
    click_button "delete some-title-3"
    expect(page).not_to have_content("some-title-3")
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
        components {
          heading size: 2, text: "My Collection"

          partial :content
        }
      end

      def content
        partial {
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
              partial :paginator
            end
          end
        }
      end

      def paginator
        partial {
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
        }
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
