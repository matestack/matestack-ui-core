# Essential Guide 8: Collection and async component

Welcome to the eigth part of our essential guide about building a web application with matestack.

## Introduction

In this part, we will improve the index page by making use of some of matestacks unique features!

In this guide, we will
- refactor the index page to use matestacks `collection` component
- add pagination and basic search functionality to it
- use matestack `async` component from the [sixth guide](/docs/guides/essential/06_async_component.md)

## Prerequisites

We expect you to have successfully finished the [previous guide](guides/essential/06_async_component.md).

## Adding a simple, filterable collection

Right now, the index page displays a simple list of all persons in our database. Starring a growing database with hundreds or thousands of records, this page will become quite large and confusing. In order to avoid this, we will first change it into a filterable list and later add pagination and a search to it. We use matestacks `collection` component to achieve this easily. First we implement our list with the `collection` component in our `app/matestack/demo/pages/persons/index.rb`.

```ruby
class Demo::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    @person_collection_id = "person-collection"
    current_filter = get_collection_filter(@person_collection_id)
    person_query = Person.all
    filtered_person_query = person_query.where("last_name LIKE ?", "%#{current_filter[:last_name]}%")
    @person_collection = set_collection({
      id: @person_collection_id,
      data: filtered_person_query
    })
  end

  def response
    filter
    async id: 'person-list', rerender_on: "#{@person_collection_id}-update" do
      content
    end
    transition path: new_person_path, text: 'Create person'
  end

  def filter
    collection_filter @person_collection.config do
      collection_filter_input key: :last_name, type: :text, placeholder: "Filter by Last name"
      collection_filter_submit do
        button text: "Apply"
      end
      collection_filter_reset do
        button text: "Reset"
      end
    end
  end

  def content
    collection_content @person_collection.config do
      @person_collection.data.each do |person|
        person_teaser person: person
      end
    end
  end

end
```

What's going on here? Let's break it down and go through it one part after another:

`include Matestack::Ui::Core::Collection::Helper` is being added to the page to add the necessary helpers for collections.

Within the prepare method we choose an id for our collection, define a default `person_query` and a filtered query which uses the filter param `last_name` to further filter the `person_query`. With `set_collection` we pass these as as hash to our collection and configure it this way. 

In our response method we added three new parts.
- A partial for the filter component. It uses a `collection_filter` component which represents a form wrapper for collection filter inputs. Inside the block we use a `collection_filter_input` component to render a text input for the `last_name`. Underneath like in forms we have a wrapper for the submit action, if the contents of the block is clicked, the form will be submitted. Followed by a reset wrapper, which will reset the form if its content is clicked.

- An async component. The `collection` component requires the content of it to be wrapped inside a async component with `rerender_on` set to the collection id followed by '-update'. When the collection filter is submitted or reset it will trigger this event so the collection content gets updated and rerendered matching the new filters.

- A content partial. The content partial takes care of rendering the records contained in the collection. It should render the same content, as our index page did before in the `response`method. The records should be wrapped inside a `collection_content` component, which needs our collection config as parameter. Inside it we iterate over each record the collection contains, by accessing its `data` method.

Now, run `rails s` and head over to [localhost:3000](http://localhost:3000/) to check out what has changed. Apparently, the changes are not very visible to the website visitor, but you now can filter your persons by last name and already have laid the basis for more features that we will add in a moment!

Let's save the new status quo to Git - this makes it easier to see where changes to the code are applied later on:

```sh
git add . && git commit -m "Refactor person index page to use collection component"
```

## Adding pagination

So there's a neat filter on our page now, but the list still contain hundreds or thousands of persons. This will increase page load times with an increasing number of person. To keep page loads fast and to not show more persons at once than people could process, we implement pagination, showing only 6 items per page. We do this by configuring the `collection` component appropriately.

Within the `prepare` method, we update the `set_collection` call to enable pagination. There should be 6 person teaser per page.

```ruby
@person_collection = set_collection({
  id: person_collection_id,
  data: filtered_person_query,
  init_limit: 6,
  filtered_count: filtered_person_query.count,
  base_count: person_query.count
})
```

By setting an `init_limit`, we configure the maximum amount of items displayed on one page (this does not refer to matestack pages, but the collection component splitting the collection into smaller chunks, which typically are pages, therefore the name pagination). In order for our collection to know how many pages there are for this collection we need to pass in the count of filtered records as well as the base count, representing the count of records without any filtering.

To only render the correct amount of persons and to allow the pagination to work, we need to update our `content` partial.
Instead of iterating over the `data` of the collection we know need to iterate over `paginated_data`. Also the user should be able to switch between the different pages, therefore we add a paginator partial.

```ruby
def content
  collection_content @person_collection.config do
    @person_collection.paginated_data.each do |person|
      person_teaser person: person
    end
    partial :paginator
  end
end
```

Our `paginator` partial takes care of rendering the page links and displaying information like how many records out of all are displayed. Let's add the `paginator` partial

```ruby
def paginator
    plain "showing #{@person_collection.from}"
    plain "to #{@person_collection.to}"
    plain "of #{@person_collection.filtered_count}"
    plain "from total #{@person_collection.base_count}"
    collection_content_previous do
      button text: "previous"
    end
    @person_collection.pages.each do |page|
      collection_content_page_link page: page do
        button text: page
      end
    end
    collection_content_next do
      button text: "next"
    end
  end
```

What does the `paginator` partial exactly do? At first we render information about how many records we see, how many there are etc. All this information is available through our collection, which we saved in the instance variable `@person_collection`. Next we render a 'previous' button, which will load the previous page. Afterwards we render a button for each page, labelled with the page number, which will load the according page. And at last we render a 'next' button, which will load the next page.

Make sure to run `rails s` and head over to [localhost:3000](http://localhost:3000/) to check out the changes! As you should see, the visible persons should be reduced to six, and below them, it shows not only the currently displayed range of persons, but also handy buttons to browse the different *collection pages* (not to be confused with the `matestack` pages in `app/matestack/demo/pages/*`)!

Again, let's commit the new status quo to Git before enhancing things once more:

```sh
git add . && git commit -m "Add pagination to collection component on person index page"
```

## Adding ordering

Let's spice it up by adding another feature: Dynamically ordering our displayed records the way we like!

In the prepare method, define the `current_order` as displayed below and pass it to the `filtered_person_query`:

```ruby
def prepare
  person_collection_id = "person-collection"
  current_filter = get_collection_filter(person_collection_id)
  current_order = get_collection_order(person_collection_id)

  person_query = Person.all
  filtered_person_query = person_query
  .where("last_name LIKE ?", "%#{current_filter[:last_name]}%")
  .order(current_order)

  @person_collection = set_collection({
    # ..
  })
end
```

While the changes above may work, the page visitor can't yet change the current order. So let's add another partial called `ordering` to the response method:

```ruby
def response
  filter
  ordering
  # ...
end
```

And underneath the `filter` partial definition, add the `ordering` partial as shown below:

```ruby
def ordering
  collection_order @person_collection.config do
    plain "sort by:"
    collection_order_toggle key: :last_name do
      button do
        plain "last_name"
        collection_order_toggle_indicator key: :last_name, asc: '(A-Z)', desc: '(Z-A)'
      end
    end
  end
end
```

Without much hassle, clicking on the button inside the `collection_order_toggle` now switches the order of records by the `:last_name` key.

Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to and check out what has changed! On the person index page, you should be able to alter the display order between three different states: Ascending and descending last names as well as the date the record was added. And all of this without writing a single line of JavaScript!

## Deep dive into the `collection` component

So we have come quite a way from simply displaying all the `person` records in a plain list, right? By making use of the `collection` component and adding the necessary configuration, the person index page content is now searchable, orderable and paginated! This would have required us to write a lot of javascript and a complex controller action, but with matestack `collection` component we could do it all just with a few lines of ruby.

The `collection` component was created with exactly this use case in mind - you got a collection of data (e.g. from ActiveRecord) that needs to be displayed in a filterable, ordered and paginated fashion (list, table, cards) without forcing you to write a lot of (repetitive, yet complex) logic.

Under the hood, the `collection` component consists of a couple of `Vue.js` components that listen for events (e.g. pressing the "Apply filter" button) and make sure the view snippets received from the server (e.g. the response only containing the filtered person records) get applied correctly.

From the developer's perspective, here is a more detailed overview of the main building blocks of this component:

1. A collection gets instantiated using the `set_collection` method which receives all the important configuration options
  - `id` and `data`
  - `init_limit`, `filtered_count`, `base_count` if the collection should be paginated
2. You can add an optional `collection_filter`, using
  - `collection_filter_input` to filter for either text, number, email, date, password etc. with an input field
  - `collection_filter_submit` to apply the current input field contents on your collection
  - `collection_filter_reset` to remove the filtering conditions
3. You can add an optional `collection_order`, using
  - a `collection_order_toggle`, expecting a key to order by
  - a `collection_order_toggle_indicator` inside the `collection_order_toggle` to indicate which order is currently being displayed
4. The (mandatory) `collection_content` inside an `async` component
  - inside, you can loop through the collection's content using the `data` or `paginated_data` method of the collection, depending on whether you're using a paginated collection or not
5. An optional pagination inside the `collection_content`
  - `collection_content_previous` and `collection_content_next` let you access previous and next collection pages
  - while looping through the `pages` of the collection, you can link to all the pages in the collection by using the `collection_content_page_link` method

That's a lot of input, so it may take some time to get used to this powerful component - but it's an investment that will pay off down the road and will make your life easier.

To learn more, check out the [API documentation](docs/components/collection.md) for the `collection` component.

## Deep dive into the `async` component

Even though it was not very obvious, the `async` component was a key element of the functionality added in this guide. Take another close look to the `response` method:

```ruby
def response
  # ...

  async rerender_on: "person-collection-update" do
    partial :content
  end

  # ...
end
```

The whole collection content is wrapped inside an `async` component that gets, as you might have guessed, re-rendered on the occurrence of a specific event, namely the `person-collection-update` event. This event gets fired when
- a filter gets applied or reset
- elements inside of `collection_content_previous`, `collection_content_page_link` or `collection_content_next` get clicked
- elements inside the order toggle get clicked

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Add ordering to collection component on person index page"
```

## Recap & outlook

We learned how to use matestacks `collection` component to generate a filterable, orderable, paginatable index page and reused our knowledge about partials and the `async` component.

So what's left? In the upcoming guides, you will create your own Vue.js components and learn about other topics like styling, notifications and authorization that are part of modern web applications

So stay tuned and, once ready, head over to the next part, covering [vue.js components](/guides/essential/09_dynamic_components.md) for powerful custom components.
