# Essential Guide 5: Toggle Component

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

Welcome to the fifth part of our essential guide about building a web application with matestack.

## Introduction

In this guide, we will introduce matestacks `toggle` and `onclick` components. For this we will 
- add a show more button to the person show page
- add more content to the show page

## Prerequisites

We expect you to have successfully finished the [previous guide](/docs/guides/essential/04_forms_edit_new_create_update_delete.md).

## Adding a show more button with onclick

Let's add a show more button to the person show page. When clicked more information about the user should be shown. In our case when it was created and when it was last updated. To do this we will use matestacks `onclick` component and later the `toggle` component.

Edit the show page in `app/matestack/demo/pages/persons/show.rb`

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All Persons'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"

    onclick emit: 'show_more' do
      button text: 'Show more'
    end

    transition path: :edit_person_path, params: { id: @person.id }, text: 'Edit'
    action delete_person_config do
      button text: 'Delete person'
    end
  end

  #...

end
```

So what does the `onclick` component do? Onclick takes one argument called `emit`. The `onclick` component renders the given block and if its clicked emits an event with the specified name. In this case it emits an event with the name `show_more` when the button is clicked. In the next section you will find out, why this is useful.

## Show more content with toggle

When the show more button is clicked, we want to show more content. Above we added a button which emits a `show_more` event when clicked. So we need a component which will show its content when this event is emitted. For this we use matestacks `toggle` component. It allows us to show or hide content depending on emitted events. Let's add more content inside a `toggle` component to the show page.

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All Persons'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"

    onclick emit: 'show_more' do
      button text: 'Show more'
    end

    toggle show_on: 'show_more' do
      paragraph text: "Created at: #{I18n.l(@person.created_at)}"
      paragraph text: "Created at: #{I18n.l(@person.updated_at)}"
    end

    transition path: :edit_person_path, params: { id: @person.id }, text: 'Edit'
    action delete_person_config do
      button text: 'Delete person'
    end
  end

  #...

end
```

The `toggle` component will be hidden on page loads. When we click our 'Show more' button, the content of our `toggle` component gets visible and you can see the localized time of the person created and updated timestamp.

Run `rails s` and head over to [localhost:3000](http://localhost:3000/) and open the details of one person to test it out.

To learn more, check out the [complete API documentation](/docs/api/2-components/toggle.md) for the `toggle` component.

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "add show more toggle to person show page"
```

## Recap & outlook

We added a show more button to our persons show page and learned how to use the `onclick` and `toggle` components and what they can be used for.  

Take a well deserved rest and make sure to come back to the next part of this series, introducing the powerful [`async` component](/docs/guides/essential/06_async_component.md).
