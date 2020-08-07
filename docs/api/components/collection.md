# Matestack Core Component: Collection

Feel free to check out the [component specs](/spec/usage/components/collection_spec.rb).

The `collection` component is designed to

- display instances from a model (Active Record or similar)
- filter the displayed instances without full page reload
- paginate the displayed instances without full page reload
- order the displayed instances without full page reload

The `collection` component should be as flexible as possible while still reducing the complexity of implementing all classic collection features by hand.

## Prerequisites

We use an ActiveRecord Model in the following examples. This Model has two columns: `id` and `title`.

## Examples

### Filterable collection

In this example, we want to display ALL instances of `DummyModel` and filter the collection by title using a text input.

```ruby
class Pages::MyApp::Collection < Matestack::Ui::Page

  include Matestack::Ui::Core::Collection::Helper

  def prepare
    my_collection_id = "my-first-collection"

    current_filter = get_collection_filter(my_collection_id)

    my_base_query = DummyModel.all

    my_filtered_query = my_base_query
      .where("title LIKE ?", "%#{current_filter[:title]}%")

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query
    })
  end

  def response
    components {
      heading size: 2, text: "My Collection"

      partial :filter

      # the content has to be wrapped in an `async` component
      # the event has to be "your_custom_collection_id" + "-update"
      async rerender_on: "my-first-collection-update" do
        partial :content
      end
    }
  end

  def filter
    partial {
      collection_filter @my_collection.config do

        collection_filter_input key: :title, type: :text, placeholder: "Filter by Title"
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
      collection_content @my_collection.config do

        ul do
          @my_collection.data.each do |dummy|
            li do
              plain dummy.title
            end
          end
        end

      end
    }
  end

end
```

### Filtered & paginated collection

In this example, we want to display only a limited (10) amount of  instances of `DummyModel` at once and filter the collection by title using a text input. We want to display the classic pagination buttons and information below the list of paginated instances.

```ruby
class Pages::MyApp::Collection < Matestack::Ui::Page

  include Matestack::Ui::Core::Collection::Helper

  def prepare
    my_collection_id = "my-first-collection"

    current_filter = get_collection_filter(my_collection_id)

    my_base_query = DummyModel.all

    my_filtered_query = my_base_query
      .where("title LIKE ?", "%#{current_filter[:title]}%")

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query,
      init_limit: 10, #set a limit
      filtered_count: my_filtered_query.count, #tell the component how to count the filtered result
      base_count: my_base_query.count #tell the component how to count the total amount
    })
  end

  def response
    components {
      heading size: 2, text: "My Collection"

      partial :filter

      async rerender_on: "my-first-collection-update" do
        partial :content
      end
    }
  end

  def filter
    partial {
      collection_filter @my_collection.config do

        collection_filter_input key: :title, type: :text, placeholder: "Filter by Title"
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
      collection_content @my_collection.config do

        ul do
          # now we use paginated_data!
          @my_collection.paginated_data.each do |dummy|
            li do
              plain dummy.title
            end
          end
        end

        partial :paginator #has to be placed within the `collection_content` component!
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
```

### Filtered & paginated & ordered collection

In this example, we want to display only a limited (10) amount of  instances of `DummyModel` at once and filter the collection by title using a text input. We want to display the classic pagination buttons and information below the list of paginated instances. Additionally, we want to order the collection by title ascending or descending.

```ruby
class Pages::MyApp::Collection < Matestack::Ui::Page

  include Matestack::Ui::Core::Collection::Helper

  def prepare
    my_collection_id = "my-first-collection"

    current_filter = get_collection_filter(my_collection_id)
    current_order = get_collection_order(my_collection_id) #now we need the current order state from the url params

    my_base_query = DummyModel.all

    my_filtered_query = my_base_query
      .where("title LIKE ?", "%#{current_filter[:title]}%")
      .order(current_order) # and apply the state to the query

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query,
      init_limit: 10,
      filtered_count: my_filtered_query.count,
      base_count: my_base_query.count
    })
  end

  def response
    components {
      heading size: 2, text: "My Collection"

      partial :filter
      partial :ordering

      async rerender_on: "my-first-collection-update" do
        partial :content
      end
    }
  end

  def filter
    partial {
      collection_filter @my_collection.config do

        collection_filter_input key: :title, type: :text, placeholder: "Filter by Title"
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
            # we use an "arrow up (unicode: &#8593;)"
            # and and an "arrow down (unicode: &#8595;)" to
            # visualize the current order state
            collection_order_toggle_indicator key: :title, asc: '&#8593;', desc: '&#8595;'
            plain "title"
          end
        end

      end
    }
  end

  def content
    partial {
      collection_content @my_collection.config do

        ul do
          @my_collection.paginated_data.each do |dummy|
            li do
              plain dummy.title
            end
          end
        end

        partial :paginator #has to be placed within the `collection_content` component!

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
```

### Action enriched collection

In this example, we want to display ALL instances of `DummyModel` and filter the collection by title using a text input. Additionally we want to be able to delete an item of the list using the `action` component.

```ruby
class Pages::MyApp::Collection < Matestack::Ui::Page

  include Matestack::Ui::Core::Collection::Helper

  def prepare
    my_collection_id = "my-first-collection"

    current_filter = get_collection_filter(my_collection_id)

    my_base_query = DummyModel.all

    my_filtered_query = my_base_query
      .where("title LIKE ?", "%#{current_filter[:title]}%")

    @my_collection = set_collection({
      id: my_collection_id,
      data: my_filtered_query
    })
  end

  def response
    components {
      heading size: 2, text: "My Collection"

      partial :filter

      async rerender_on: "my-first-collection-update" do
        partial :content
      end
    }
  end

  def filter
    partial {
      collection_filter @my_collection.config do

        collection_filter_input key: :title, type: :text, placeholder: "Filter by Title"
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
      collection_content @my_collection.config do

        ul do
          @my_collection.data.each do |dummy|
            li do
              plain dummy.title
              action my_action_config(dummy.id) do
                button text: "delete"
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
      path: :my_delete_path,
      params:{
        id: id
      },
      success: {
        emit: "my-first-collection-update"
      }
    }
  end

end
```
