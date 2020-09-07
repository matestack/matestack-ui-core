# Essential Guide 6: Async Component

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

Welcome to the sixth part of our essential guide about building a web application with matestack.

## Introduction

In this guide, we will introduce matestacks `async` component. For this we will 
- render all persons in a list with a delete button
- use the `async` component to update the list when a person is deleted

## Prerequisites

We expect you to have successfully finished the [previous guide](guides/essential/05_toggle_component.md).

## Add a delete button

First we want to add the possibility to delete persons directly from the index page. We accomplish this by adding a delete button like we did on the show page using an `action` component for every person on the index page. Change your index page `app/matestack/demo/persons/index.rb` accordingly.

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
          action delete_person_config(person) do
            button 'Delete'
          end
        end
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

We added a delete button like we did on the show page, with only a few differences. First is that our config function takes a person parameter. We need to do this in order to generate the correct route for every person. Second, in case of an successful request, we no longer follow the redirect response, but instead emit an `person-deleted` event. If we now click on the delete button of a person, it will be deleted on the server, but we will not see any difference in our view, because the request happens asynchronously and we don't redirect on success like we did on the show page. When we reload the page, we will see that the person we deleted is now gone.

But how can we easily update the list, when the delete action was successful? Read further as we introduce the `async` component.

## Rerender list when person is deleted

When a person is deleted an event is emitted, but nothing more happens, but we want to update the list of persons, so we no longer see the deleted person in the list. In order to achieve this we could write some javascript which would manipulate the dom or we can use matestacks `async` component and get the result we want in no time and without touching any javascript. Okay, so let's update our index page like this:

```ruby
class Demo::Pages::Persons::Index

  def prepare
    @persons = Person.all
  end

  def response
    ul do
      async id: 'person-list', rerender_on: 'person-deleted' do
        @persons.each do |person|
          li do
            plain person.first_name
            strong text: person.last_name
            transition text: 'Details', path: person_path(person)
            action delete_person_config(person) do
              button 'Delete'
            end
          end
        end
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

What happens here? An `async` component can render or rerender content asynchronously, either on events or on page loads. In this case, we give the `async` component an `id`, which is required, and specify with `rerender_on: 'person-deleted'` that it should rerender its content when a 'person-deleted' event was emitted.

Now when we visit [localhost:3000](http://localhost:3000) and click on the delete button of one of the persons the person should dissappear from the list. The action component calls the delete action and on success emits the `person-deleted` event. The `async` component therefore requests its content asynchronously and the server resolves the content of the async component and response with the updated list items, contained inside the `async` component. 

To learn more, check out the [complete API documentation](/docs/api/2-components/async.md) for the `async` component.

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "add delete button to person list and update it dynamically"
```

## Recap & outlook

We added a delete button to our person list on the index page. When a person is deleted our list gets automatically updated without even reloading the page, just by updating the part that is needed. And all of that with a few lines of code and without writing any javascript.

Take a well deserved rest and make sure to come back to the next part of this series, introducing [partials and custom components](/docs/guides/2-essential/07_partials_and_custom_components.md).
