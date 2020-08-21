# Essential Guide 3: Person Index, Show, Transition

Welcome to the third part of our essential guide about building a web application with matestack.

## Introduction

In the [previous guide](guides/essential/02_active_record.md), we added an ActiveRecord model to our project, added some fake persons to our database and displayed them on an index page.

In this guide, we will
- a detail page for every person
- dive more into the concept of page transitions

## Prerequisites

We expect you to have successfully finished the [previous guide](guides/essential/02_active_record.md).

## Update person controller and routes

We want to add a detail page for our persons. In order to do that we need to update our `routes.rb` to include the show action for persons.
Also now is a good time to swap our rails root route to our persons index action.

```ruby
Rails.application.routes.draw do
  root to: 'persons#index'

  resources :persons, only: [:index, :show]
end
```

Next we need to add the show action to our person controller. Inside it we find the person matching the id from the path, like you would normally do in Rails.

```ruby
class PersonsController < ApplicationController
  matestack_app Demo::App

  def index
    render Demo::Pages::Person::Index
  end

  def show
    @person = Person.find_by(id: params[:id])
    render Demo::Pages::Person::Show
  end

end
```

## Page transitions

In `app/matestack/demo/app.rb`, replace the contents with the code snippet below in order to add a navigation transition to the root path in our app layout.

```ruby
class Demo::App < Matestack::Ui::App

  def response
    nav do
      transition path: root_path, text: 'Persons'
    end
    header do
      heading size: 1, text: 'Demo App'
    end
    main do
      yield_page
    end
    footer do
      hr
      small text: 'These guides are provided by matestack'
    end
  end

end
```

## Person index page

In order to view the details of a person we add a transition to every person on the index page linking to the persons show page.

```ruby
class Demo::Pages::Persons::Index

  def prepare
    @persons = Person.all
  end

  def response
    ul do
      @persons.each do |person|
        li do
          plain person.first_name
          strong text: person.last_name
          transition text: 'Details', path: person_path(person)
        end
      end
    end
  end

end
```

## Person detail page

Next we create the show page for a person. Therefore we create a file called `show.rb` alongside the `index.rb` inside `app/matestack/demo/pages/persons`.

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All persons'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"
  end

end
```

The show page displays the persons firstname and lastname in a _h2_ tag and underneath the persons role in a _p_ tag. Above those information is a transition to the persons index page.

As you might see, we can access instance variables from controllers and rails helpers inside of our pages. This is also applicable for apps and components. We have access to everything we would have access to in a standard rails view.

## Further introduction: Page transitions

Now that we've used them a couple of times, let's focus on the `transition` component a bit longer:

When you want to change between different pages within the same `matestack` app, using a `transition` component gives you a neat advantage: After clicking the link, instead of doing a full page reload, only the page content within your app gets replaced - this leads to a better performance (faster page load) and a more app-like feeling for your users or page visitors!

For links that go outside your `matestack` app, require a full page reload or reference URLs outside your domain, make sure to use the [link component](/docs/api/2-components/link.md) instead!

To learn more, check out the [complete API documentation](docs/api/2-components/transition.md) for the `transition` component.

## Local testing

Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to test the changes! You should be able to browse through the various persons in the database and switch between the different pages using the transition links.

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Add index/show matestack pages for person model (incl. controller, routes), update demo matestack app"
```

## Recap & outlook

Our **person** model now has a dedicated index and show page. The pages within our `matestack` app are properly linked to each other. We learned how we can access data and use rails helpers inside of pages, apps and components and how transitions in more detail work.

Let's continue and add the necessary functionality for adding new persons and editing existing ones in the [next part of the series](/guides/essential/04_form_create_update_delete.md).
