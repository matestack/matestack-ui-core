# Essential Guide 6: Custom Static Components
Welcome to the sixth part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/05_collection_async.md), we introduced both async and collection components. In this part, we will discover how you can create custom static `matestack` components, either by orchestrating existing `matestack-ui-core` components or by using `*.haml*` files!

In this guide, we will
- refactor the **Index** and **Show** pages to use a custom static `matestack` component
- add a custom static `matestack` component to the **App** layout

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/05_collection_async.md) and no uncommited changes in your project.

## Extracting content to a custom static component
Let's dive right into it! Firstly, to allow for custom components, we need to update our `ApplicationController` to include a local components registry. It's simple and works like this:

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry
end
```

Say we want to replace the list of persons on the index page with cards (unstyled for now, but will fix that soon) - this calls for a custom static component, since those cards potentially can be (and within this guide will be) reused in different places within our application.

For the custom `matestack` card component, create a file in `app/matestack/components/person/card.rb` and add the following content:

```ruby
class Components::Person::Card < Matestack::Ui::StaticComponent

  def prepare
    @person = @options[:person]
  end

  def response
    div do
      paragraph text: "#{@person.first_name} #{@person.last_name} "
      transition path: :person_path, params: {id: @person.id}, text: '(Details)'
    end
  end

end
```

Looks familiar, right? Like with `matestack-ui-core` pages, custom components make use of `prepare` and `response` methods. In this simple example, we only orchestrate existing `matestack-ui-core` components.

Remember the registry we included in the `ApplicationController`? Let's add it in `/app/matestack/components/registry.rb` and register our new `Person::Card` component properly:

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    person_card: Components::Person::Card
  )

end
```

After registering it, we can now use our component as `person_card` (or any other name, if you feel creative)! Please note that the component registry gets cached on application starts, so removing components later on only takes effect after a re-start of the application. Adding components does work without a restart, though.

On `app/matestack/demo/pages/persons/index.rb`, update the content of the `content` partial to look like this:

```ruby
def content
  collection_content @person_collection.config do

    @person_collection.paginated_data.each do |person|
      person_card person: person
    end

    partial :paginator
  end
end
```

See how we're calling the custom component as `person_card`, just like any other `matestack` component, and we're passing the current `|person|` variable as an argument?

When you start your application locally now, the missing list bullet points should be the only visible change. As said before, we will take care of styling soon - but first, let's reuse our newly introduced component!

## Reusing the custom static component
How about displaying three random persons from the database on the Person **Show** page, each within a card? It's as simple as below:

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def prepare
    @other_persons = Person.where.not(id: @person.id).order("RANDOM()").limit(3)
  end

  def response
    # ...
    partial :other_persons
  end

  def other_persons
    heading size: 3, text: 'Three other persons:'
    @other_persons.each do |person|
      person_card person: person
    end
  end

  # ...
end
```

We query the database for the three random records in the `prepare` method, add a partial for better composability and then loop through the records, handing each record as input to our custom card component!

## Using HAML in custom static components
If you need more fine-grained control of your view layer or want to reuse some old HAML files, you can also create custom components like this:

Create a file called `app/matestack/components/person/disclaimer.rb` and add this content:

```ruby
class Components::Person::Disclaimer < Matestack::Ui::StaticComponent
end
```

Since this component does not have a `response` method, `matestack` automatically looks for a `disclaimer.haml` file right next to it. Note that you can still combine a `prepare` method and used variables/data prepared there in the HAML template, though.

So let's add the `disclaimer.haml` file in `app/matestack/components/person/` and add a simple paragraph:

```haml
%p
  None of the presented names belong to and/or are meant to refer to existing human beings. They were created using a "Random Name Generator".
```

To display this disclaimer on every page within our `Demo::App`, we need to register it in the `/app/matestack/components/registry.rb`:

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    person_card: Components::Person::Card,
    person_card: Components::Person::Disclaimer
  )

end
```

Afterwards, add it to `app/matestack/demo/app.rb` within the `main`-block:

```ruby
# ...
  main do
    yield_page
    person_disclaimer
    # ...
  end
# ...
```

Unlike the person card, we don't need to hand over inputs in this case. Spin up your application and check out the changes!

## More information on custom static components
Even though we only covered very basic cases here, you may already have some idea of how powerful custom components can be!
By leveraging useful namespaces and calling custom components within other custom components, you can get quite fancy and build complex user interfaces while keeping the code maintainable and reasonable.

Side note: Custom components also give you a neat way of porting legacy `*.haml` views over to be used on `matestack` pages (`*.html` and `*.slim` files are supposed to follow soon)!

To learn more, check out the [extend API documentation](docs/extend/custom_static_components.md) for custom static components.

## Saving the status quo
As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add app/matestack/demo/app.rb app/matestack/demo/pages/persons/ app/matestack/components/person app/matestack/components/registry.rb && git commit -m "Refactor person index&show page to use custom components, add custom component registry, add disclaimer component to app layout"
```

## Deployment
After you've finished all your changes and commited them to Git, run

```sh
git push heroku master
```

to deploy your latest changes. Check the results via

```sh
heroku open
```

and check that it still works as expected!

## Recap & outlook
Today, we covered a great way of extracting recurring UI elements into reusable components by leveraging existing the existing `matestack-ui-core` component library. Of course, we only covered a very basic use case here and there are various ways of using custom static components! Make sure to play around with the different configuration options and see how your app can benefit!

If you need even more powerful customization possibilities, head over to the next part of this series, covering [dynamic components](/guides/essential/07_dynamic_components.md) for enhanced client side interactivity!
