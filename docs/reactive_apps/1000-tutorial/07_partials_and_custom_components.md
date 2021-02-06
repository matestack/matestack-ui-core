# Essential Guide 7: Partials and custom components

Demo: [Matestack Demo](https://demo.matestack.io)  
 Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

Welcome to the seventh part of our tutorial about building a web application with matestack.

## Introduction

In this part, we will discover how we can create custom components with matestack to declutter and better structure our code.

In this guide, we will

* refactor our new and edit forms with partials
* refactor our person index page with components
* refactor the show page and reuse our component
* add a custom component to our app

## Prerequisites

We expect you to have successfully finished the [previous guide](06_async_component.md).

## Using partials

Partials are an easy way to structure code in apps, pages and components. Let's take a look at how partials work with an example, changing our first page.

```ruby
class Demo::Pages::FirstPage < Matestack::Ui::Page

  def response
    div do
      heading text: 'Hello World!', size: 1
    end
    description
  end

  private

  def description
    paragraph text: 'This is our first page, which now uses a partial'
  end

end
```

Partials can be used to split view code apart, in order to write better structurem, more readable, cleaner code. As we can see in the example, a partial is nothing else but a method call. The method implements a view part. Partials can also be used within partials.

Now we know what partials can do, lets refactor our person new and edit pages. They share a lot of same code, both containing the same form. To reuse our code, we create a `Demo::Pages::Person::Form` page, from which both new and edit will inherit. Let's create it in `app/matestack/demo/pages/persons/form.rb`

```ruby
class Demo::Pages::Persons::Form < Matestack::Ui::Page

protected

def person_form(button_text)
  form person_form_config, :include do
    label text: 'First name'
    form_input key: :first_name, type: :text
    br
    label text: 'Last name'
    form_input key: :last_name, type: :text
    br
    label text: 'Person role'
    form_select key: :role, type: :radio, options: Person.roles.keys
    br
    form_submit do
      button text: button_text
    end
  end
end

def person_form_config
  raise 'needs to be implemented'
end
```

Now we have a form page, which only implements a partial `person_form` containing the new and edit form for our person. It takes one parameter, which will be used as the button label, in order to allow different labels for new and edit. We know from an earlier chapter, that a form needs a hash as parameter. Our `person_form_config` method should return the config hash. As this hash changes, depending on the page we use our form, we need to overwrite it in the class where we inherit from our form.

First we refactor our new page. We change it, so it inherits from our form page, replace the form with the partial and rename the method returning the form config hash to match the name of our form page.

```ruby
class Demo::Pages::Persons::New < Demo::Pages::Persons::Form

  def response
    transition path: persons_path, text: 'All persons'
    heading size: 2, text: 'Create a new person'
    person_form 'Create person'
  end

  def person_form_config
    {
      for: Person.new,
      method: :post,
      path: persons_path,
      success: {
        transition: {
          follow_response: true
        }
      }
    }
  end

end
```

Our new page looks now much cleaner. We overwrite `person_form_config`, which is used in the partial as an input for the required hash parameter of the form, setting the correct configurations for our new form.

After this we can refactor our edit page accordingly. Inherit from our form page, use the form partial and overwrite the config method.

```ruby
class Demo::Pages::Persons::Edit < Demo::Pages::Persons::Form

  def response
    transition path: :person_path, params: { id: @person.id }, text: 'Back to detail page'
    heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}"
    person_form 'Save changes'
  end

  def person_form_config
    {
      for: @person,
      method: :patch,
      path: :person_path,
      params: {
        id: @person.id
      },
      success: {
        transition: {
          follow_response: true
        }
      }
    }
  end

end
```

We successfully refactored our code using partials, so it's better structured, more readable and we keep it dry \(don't repeat yourself\).

Visit [localhost:3000](http://localhost:3000) and navigate to the new and edit pages, to check that everything works like before.

## Custom components

Custom components can be used to create reusable components, representing ui parts. They can be just a button, or a more complex card or even a complete slider, which reuses the card component.

In the next steps we want to refactor our person index page, by creating a person teaser component.

But first, we need to create a component registry. Every custom components need to be registered through a component registry. It is possible to use multiple registries to keep for example admin components apart from public components, but in this guide we keep it simple and only use one registry. Let's create it in `app/matestack/components/registry.rb`. As our components should be reusable by all apps, pages and components, we create them in the `app/matestack/components` folder, where our registry lives.

```ruby
module Components::Registry
  Matestack::Ui::Core::Component::Registry.register_components(
    person_teaser: Components::Persons::Teaser
  )
end
```

In the above registry, we registered a `person_teaser` component, which refers to the class `Components::Person::Teaser`. Let's implement this class, our first component, in `app/matestack/components/persons/teaser.rb`.

```ruby
class Components::Persons::Teaser < Matestack::Ui::Component

  requires :person

  def response
    div class: 'teaser' do
      heading text: "#{person.first_name} #{person.last_name}", size: 3
      transition text: '(Details)', path: person_path(person)
      action delete_person_config(person) do
        button 'Delete'
      end
    end
  end

  private

  def delete_person_config(person)
    {
      method: :delete,
      path: persons_path(person)
      success: {
        emit: 'person-deleted'
      },
      confirm: {
        text: 'Do you really want to delete this person?'
      }
    }
  end

end
```

Let's take a look whats happening in our component. Components need to inherit from matestacks component `Matestack::Ui::Component`. They also define a response method, which contains the content that is rendered. As we want to display information from a person, we need access to a person in our component. To achieve this components offer you the possibility to define required and optional properties with the `requires` and `optional` methods. We can pass as many symbols as we like to one of the calls or call it multiple times. Every so defined property is accessible through a method with the same name as the symbol. In the `response` we create a div containing a _h3_ tag with the full name of the person, a transition to the show page and the delete button we also had on the index page.

In order to use this our teaser component we need to include the component registry in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry
end
```

Now we can use our custom person teaser by calling `person_teaser` to refactor our list of person on our index page. Instead of iterating over the persons and creating a list element for every person, we now can iterate over the persons and call our component passing the person to it.

```ruby
class Demo::Pages::Persons::Index

  def prepare
    @persons = Person.all
  end

  def response
    ul do
      async id: 'person-list', rerender_on: 'person-deleted' do
        @persons.each do |person|
          person_teaser person: person
        end
      end
    end
  end

end
```

Using our custom component is as easy as calling the name we defined in our registry. Required and optional propertys are passed to a component as a hash. If we would not provide a person to our person teaser the component would raise an exception as a person is required. Optional properties are as the name suggests optional and therefore can be left out.

When you start your application locally now, the missing list bullet points should be the only visible change. We will take care of styling soon - but first, let's reuse our newly introduced component!

## Using HAML in custom components

If you need more fine-grained control of your view layer or want to reuse some old HAML files, you can also create custom components like this:

Create a file called `app/matestack/components/person/disclaimer.rb` and add this content:

```ruby
class Components::Person::Disclaimer < Matestack::Ui::Component
end
```

Since this component does not have a `response` method, matestack automatically looks for a `disclaimer.haml` file right next to the component. Note that you can still use a `prepare` method.

So let's add the `disclaimer.haml` file in `app/matestack/components/person/` and add a simple paragraph:

```text
%p
  None of the presented names belong to and/or are meant to refer to existing human beings. They were created using a "Random Name Generator".
```

To display this disclaimer on every page within our `Demo::App`, we need to register it in the `/app/matestack/components/registry.rb`:

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    person_teaser: Components::Person::Teaser,
    person_disclaimer: Components::Person::Disclaimer
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

Different from our `person_teaser`, we don't need to hand over properties to our `person_disclaimer`. Spin up your application and check out the changes!

## More information on custom components

Even though we only covered very basic cases here, you may already have some idea of how powerful custom components can be! By leveraging useful namespaces and calling custom components within other custom components, you can get quite fancy and build complex user interfaces while keeping the code maintainable and reasonable.

Side note: Custom components also give you a neat way of reusing your `*.haml` views with matestack \(erb and slim support will be added soon\).

To learn more, check out the [basic building blocks](../) guides section about custom components.

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```bash
git add . && git commit -m "Refactor person new, edit, index, show page to use custom components, add custom component registry, add disclaimer component to app"
```

## Recap & outlook

Today, we covered a great way of extracting recurring UI elements into reusable components with matestack. Of course, we only covered a very basic use case here and there are various ways of using custom components.

Take a well deserved rest and make sure to come back to the next part of this series, introducing the powerful [`collection` component](08_collection_async.md).

