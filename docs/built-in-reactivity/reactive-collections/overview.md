# Overview

The `collection` component helps you display Active Record model or similar collections and adding features like filtering, paginating and ordering with ease. Each of these features requires no page reload to take effect, because the `collection` component leverages a `async` component in combination with the event hub to only reload the effected content of the collection.

As you might experienced or know, displaying a collection of components can pretty fast lead to slow page loads, because of to big collections, therefore often requiring pagination. To work with bigger collections you often need a filter or search and an ordering to improve the user experience of your app. The collection component reduces the complexity of implementing all typical collection features by hand.

In order to use a collection on your page or component you need to include Matestack's collection helper `Matestack::Ui::VueJs::Components::Collection::Helper` in the corresponding page or component. The helper provides a few methods. `set_collection` takes a hash as an argument and is responsible for setting up the collection component. It requires an `:id` and `:data`.

We recommend setting up your collection inside the `prepare` method of your page or component.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  include Matestack::Ui::VueJs::Components::Collection::Helper

  def prepare
    @collection_id = 'products-collection'
    @collection = set_collection(
      id: @collection_id,
      data: Products.all
    )
  end

  def response
    async id: 'product-collection', rerender_on: "#{@collection_id}-update" do
      collection_content @collection.config do
        @collection.data.each do |product|
          paragraph product.name
        end
      end
    end
  end

end
```

This is a basic collection component rendering all products. So far there is no benefit in using the collection component instead of just rendering all products, but moving on from this we can now easily implement a pagination, filtering and ordering. The `async` component wrapping the `collection_content` is important to enable reloading filtered, ordered or paginated collections later without page reloads. A collection filter, order or pagination emits a "_collection\_id_-update" event.

## Pagination

Limiting the amount of displayed collection items increases our load time for bigger collections drastically, but a user needs to be able to click through all of your items. We achieve this by using pagination.

Pagination can be achieved quite easily with matestacks collection. We need to add a `:init_limit` and `:base_count` to our arguments of the `set_collection` call and change the usage of `@collection.data` to `@collection.paginated_data`. In order to give the user the option to switch between pages we add a pagination which display links to the previous and next page as well as all pages by using matestack collection helpers `collection_content_previous`, `collection_content_next`, `collection_content_page_link`. It also displays a few information about the pagination.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  include Matestack::Ui::VueJs::Components::Collection::Helper
  
  def prepare
    @collection_id = 'products-collection'
    base_query = Products.all
    @collection = set_collection(
      id: @collection_id,
      data: base_query,
      init_limit: 20,
      base_count: base_query.count
    )
  end

  def response
    async id: 'product-collection', rerender_on: "#{@collection_id}-update" do
      collection_content @collection.config do
        # now we use paginated_data!
        @collection.paginated_data.each do |product|
          paragraph product.name
        end
        # pagination has to be placed within the collection_content!
        pagination_partial
      end
    end
  end

  def pagination_partial
    plain "showing #{collection.from}"
    plain "to #{@collection.to}"
    plain "of #{@collection.base_count}"
    collection_content_previous do
      button "previous"
    end
    @collection.pages.each do |page|
      collection_content_page_link page: page do
        button page
      end
    end
    collection_content_next do
      button "next"
    end
  end

end
```

## Filtering

Filtering a collection can be done by using the `collection_filter` helper along with the `collection_filter_input`, `collection_filter_submit` and `collection_filter_reset` helpers. The input values of your collection filter are accessible in the prepare statement by using `get_collection_filter(id)`, which takes the collection id and returns a hash containing the input keys and values.

Let's filter our collection by name.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  include Matestack::Ui::VueJs::Components::Collection::Helper

  def prepare
    @collection_id = 'products-collection'
    base_query = Products.all
    filtered_query = base_query

    filter = get_collection_filter(@collection_id)
    filtered_query = Products.where('name LIKE ?', filter[:name]) if filter[:name].present?

    @collection = set_collection(
      id: @collection_id,
      data: filtered_query,
      init_limit: 20,
      base_count: base_query.count,
      filtered_count: filtered_query.count
    )
  end

  def response
    filter_partial
    async id: 'product-collection', rerender_on: "#{@collection_id}-update" do
      collection_content @collection.config do
        # here we use paginated_data!
        @collection.paginated_data.each do |product|
          paragraph product.name
        end
        # pagination has to be placed within the collection_content!
        pagination_partial
      end
    end

  end

  def filter_partial
    collection_filter @collection.config do
      form_input key: :name, type: :text
      button 'Filter', type: :submit
      collection_filter_reset do
        button 'Reset'
      end
    end
  end

  def pagination_partial
    plain "showing #{@collection.from}"
    plain "to #{@collection.to}"
    plain "of #{@collection.base_count}"
    collection_content_previous do
      button "previous"
    end
    @collection.pages.each do |page|
      collection_content_page_link page: page do
        button page
      end
    end
    collection_content_next do
      button "next"
    end
  end

end
```

That's it. Now we can filter our collection by product name.

## Ordering

Ordering a collection can be achieved by using the `collection_order_toggle` helper along with `get_collection_order` to receive the selected order.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  include Matestack::Ui::VueJs::Components::Collection::Helper

  def prepare
    @collection_id = 'products-collection'
    base_query = Products.all

    order = get_collection_order(@collection_id)
    ordered_query = Products.all.order(current_order)

    @collection = set_collection(
      id: @collection_id,
      data: ordered_query,
      init_limit: 20,
      base_count: base_query.count
    )
  end

  def response
    order_partial
    async id: 'product-collection', rerender_on: "#{@collection_id}-update" do
      collection_content @collection.config do
        # here we use paginated_data!
        @collection.paginated_data.each do |product|
          paragraph product.name
        end
        # pagination has to be placed within the collection_content!
        pagination_partial
      end
    end
  end

  def order_partial
    collection_order @my_collection.config do
      plain "sort by:"
      collection_order_toggle key: :title do
        button do
          plain "Title"
          collection_order_toggle_indicator key: :title, asc: '&#8593;', desc: '&#8595;'
        end
      end
    end
  end

  #...

end
```

## Using actions in collections

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  include Matestack::Ui::VueJs::Components::Collection::Helper
  
  def prepare
    @collection_id = 'products-collection'
    base_query = Products.all
    @collection = set_collection(
      id: @collection_id,
      data: base_query,
      init_limit: 20,
      base_count: base_query.count
    )
  end

  def response
    async id: 'product-collection', rerender_on: "#{@collection_id}-update" do
      collection_content @collection.config do
        @collection.paginated_data.each do |product|
          paragraph product.name
          action my_action_config(product.id) do
            button 'delete'
          end
        end
        # pagination has to be placed within the collection_content!
        pagination_partial
      end
    end
  end
  
  def my_action_config id
    {
      method: :delete,
      path: my_delete_path(id: id),
      success: {
        emit: "#{@collection_id}-update" # has to match the rerender_on event schema!
      }
    }
  end
  
  # ...

end

```

