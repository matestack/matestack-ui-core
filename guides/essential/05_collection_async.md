# Essential Guide 5: Collection & Async component
Welcome to the fifth part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/04_forms_edit_new_create_update_delete.md), we added forms and pages - now we can add new persons and modify existing ones. In this part, we will improve the **Index** page by making use of some of `matestack-ui-core`'s most powerful features!

In this guide, we will
- refactor the **Index** page to use the `matestack` collection component, adding pagination and basic search functionality
- introduce the concept of `matestack` async components

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/04_forms_edit_new_create_update_delete.md) and no uncommited changes in your project.

## Adding a simple, filterable collection
Right now, the **Index** page displays a simple list with all the person records in the database. This will become an overly crowded page with a long loading time quite soon, so replace the contents of `app/matestack/demo/pages/persons/index.rb` with the following:

```ruby
class Demo::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    person_collection_id = "person-collection"

    current_filter = get_collection_filter(person_collection_id)

    person_query = Person.all

    filtered_person_query = person_query
    .where("last_name LIKE ?", "%#{current_filter[:last_name]}%")

    @person_collection = set_collection({
      id: person_collection_id,
      data: filtered_person_query
    })
  end

  def response
    partial :filter

    async rerender_on: "person-collection-update" do
      partial :content
    end

    transition path: :new_person_path, text: 'Create new person'
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

      ul do
        @person_collection.data.each do |person|
          li do
            plain "#{person.first_name} #{person.last_name} "
            transition path: :person_path, params: {id: person.id}, text: '(Details)'
          end
        end
      end

    end
  end

end
```

What's going on here? Let's break it down and go through it one part after another:
- `include Matestack::Ui::Core::Collection::Helper` is being added to the page to enable the magic that follows
- within the `prepare` method/statement, we configure the `collection` by giving it an `id`, handing over a record fetched from the database and defining the filter query
- the `response` method/statement gets broken apart into smaller parts
  - a partial for the filter components
  - a partial for the actual collection content, wrapped in an `async` component
  - the link/transition to the **New** page, which remains unchanged
- the filter partial receives an configuration param and wraps special `collection_filter_input`, `collection_filter_submit`, `collection_filter_reset` components - they look and feel a bit similar to the forms components introduced in the previous guide, but still work quite differently ;)
- the content partial resembles our former **Index** page `response`, but still needs to be wrapped in a `collection_content` and, instead of an ActiveRecord instance, we loop over `@person_collection.data`.

Now, run `rails s` and head over to [localhost:3000](http://localhost:3000/) to check out what has changed. Apparently, the changes are not very visible to the website visitor, but you now can filter your persons by last name and already have laid the basis for more powerful features that we will add in a moment!

Let's save the new status quo to Git - this makes it easier to see where changes to the code are applied later on:

```sh
git add app/matestack/demo/pages/persons/index.rb && git commit -m "Refactor person index page to use collection component"
```

## Adding pagination
So there's a neat filter on our page now, but the list still contains all the **person** records from the database. As stated above, this will become a performance problem down the road, so let's leverage the powerful and built-in pagination functionality.

Within the `prepare` method, update the `@person_collection` with further configuration:

```ruby
@person_collection = set_collection({
  id: person_collection_id,
  data: filtered_person_query,
  init_limit: 3,
  filtered_count: filtered_person_query.count,
  base_count: person_query.count
})
```

By setting an `init_limit`, the maximum of items displayed gets configured. In order for our collection to know when this limit is reached, both `filtered_count` and `base_count` need to be computed and passed as well.

To make those changes work, the `content` partial needs to be updated - towards the end of the `collection_content` block, add a `partial :paginator`.

Also, note that `@person_collection.data` gets replaced by `@person_collection.paginated_data`:

```ruby
def content
  collection_content @person_collection.config do

    ul do
      @person_collection.paginated_data.each do |person|
        # ...
      end
    end

    partial :paginator
  end
end
```

And, of course, the `paginator` partial needs to be defined within the page. Let's add it at the bottom:

```ruby
class Demo::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
  #...
  end

  def response
  #...
  end

  def filter
  #...
  end

  def content
  #...
  end

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

end
```

Make sure to run `rails s` and head over to [localhost:3000](http://localhost:3000/) to check out the changes! As you should see, the visible persons should be reduced to three, and below them, it shows not only the currently displayed range of database records, but also handy buttons to browse the different *collection pages* (not to be confused with the `matestack` pages in `app/matestack/demo/pages/*`)!

Again, let's commit the new status quo to Git before enhancing things once more:

```sh
git add app/matestack/demo/pages/persons/index.rb && git commit -m "Add pagination to collection component on person index page"
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

While the changes above may work, the page visitor probably misses a clue on where to change the current order. So let's add another partial called `ordering` to the response method:

```ruby
def response
  partial :filter
  partial :ordering

  # ...
end
```

And underneath the `filter` partial definition, add the `ordering` partial as show below:

```ruby
def filter
  # ...
end

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

Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to and check out what has changed! On the person **Index** page, you should be able to alter the display order between three different states: Ascending and descending last names as well as the date the record was added. And all of this without writing a single line of JavaScript!

## Deep dive into the `collection` component
So we have come quite a way from simply displaying all the `person` records in a plain list, right? By making use of the `collection` component and adding the necessary configuration, the person **Index** page content is now searchable, orderable and paginated! This would have required us to switch between Front- and Backend quite a lot while forcing us to write *a lot* more code in almost any other scenario!

The `collection` component was created with exactly this use case in mind - you got a collection of data (e.g. from ActiveRecord) that needs to be displayed in an ordered, filterable and paginated fashion (list, table, cards) without forcing you to write a lot of (repetitive, yet complex) logic!

Under the hood, the `collection` component consists of a couple of `Vue.JS` components that listen for events (e.g. pressing the "Apply filter" button) and make sure the view snippets received from the server (e.g. the response only containing the filtered **person** records) get applied correctly.

From the developer's perspective, here is a more detailed overview of the main building blocks of this component:

1. A collection gets instantiated using the `set_collection` method which receives all the important configuration options
  - `id` and `data`
  - `init_limit`, `filtered_count`, `base_count` if the collection should be paginated
2. You can add an optional `collection_filter`, using
  - `collection_filter_input` to filter for either text, number, email, date or password with an input field
  - `collection_filter_submit` to apply the current input field contents on your collection
  - `collection_filter_reset` to remove the filtering conditions
3. You can add an optional `collection_order`, using
  - a `collection_order_toggle`, expecting a key to order by
  - a `collection_order_toggle_indicator` inside the `collection_order_toggle` to indicate which order is currently being displayed
4. The (mandatory) `collection_content` inside an `async` component
  - inside, you can loop through the collection's content using the `.data` or `.paginated_data` method, depending on whether you're using a paginated collection or not
5. An optional pagination inside the `collection_content`
  - `collection_content_previous` and `collection_content_next` let you access previous and next collection pages
  - while looping through `collection_name.pages.each`, you can link to all the pages in the collection by adding the `collection_content_page_link` method

That's a lot of input, so it may take some time to get used to this powerful component - but it's an investment that will pay off down the road and will make your life easier (and your users/clients happy)!

To learn more, check out the [API documentation](docs/components/collection.md) for the `collection` component. Make sure to play around with it and feel free to open a [create a GitHub issue](https://github.com/matestack/matestack-ui-core/issues/new) if you spot any errors or have a feature request!

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

But this is not the only capability of the `async` component - it can also show and hide content on occurrence of certain events (as well as after a certain amount of time) and defer the loading of its content.

To learn more, check out the [complete API documentation](docs/components/async.md) for the `async` component.

## Saving the status quo
As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add app/matestack/demo/pages/persons/index.rb && git commit -m "Add ordering to collection component on person index page"
```

## Deployment
After you've finished all your changes and commited them to Git, run

```sh
git push heroku master
```

to deploy your latest changes (again, no migrations are needed as the database schema is still unchanged). Check the results via

```sh
heroku open
```

and take a few moments to play around with all the new functionality that has been added!

## Recap & outlook
Halfway through this 10-step guide, you not only have a full **CRUD** application up and running, but have made use of some of the most interesting features of the `matestack-ui-core` gem!

So what's left? A lot, actually! In the upcoming parts of the series, you will create your own `matestack` components (both static and dynamic ones), and other topics that are part of modern web applications, such as styling, notification and authorization, will be covered - with a focus on leveraging `matestack` features, of course.

So stay tuned and, once ready, head over to the next part, covering [static components](/guides/essential/06_static_components.md) for powerful custom building blocks.
