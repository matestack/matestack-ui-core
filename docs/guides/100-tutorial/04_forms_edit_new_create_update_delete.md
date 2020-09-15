# Essential Guide 4: Forms & Actions (Create, Update, Delete)

Demo: [Matestack Demo](https://demo.matestack.io)<br>
Github Repo: [Matestack Demo Application](https://github.com/matestack/matestack-demo-application)

Welcome to the fourth part of our essential guide about building a web application with matestack.

## Introduction

In the [previous guide](guides/100-tutorial/03_index_show_transition.md), we added index and show pages for the **person** model. In this part, we will implement the create, update and delete part of our CRUD application. For this we will introduce the matestack `forms`.

In this guide, we will
- add a new page and action action to create new persons
- add an edit page and action to modify existing persons
- add an delete action to delete existing persons
- introduce the concept of matestack forms
- introduce the concept of matestack actions

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/100-tutorial/03_index_show_transition.md).

## Updating the person model

All persons should have a first name, last name and a role. Therefore we add validations to our person model for these three attributes in `person.rb`.

```ruby
validates :first_name, presence: true
validates :last_name, presence: true
validates :role, presence: true
```

We only check for presence of this three attributes.

## Preparing routes & controller

In your `config/routes.rb`, change

```ruby
resources :persons, only: [:index, :show]
```

to

```ruby
resources :persons
```

in order to let rails generate all CRUD routes for persons.

Then, in the `persons_controller.rb`, update the contents like this:

```ruby
class PersonsController < ApplicationController
  matestack_app Demo::App

  before_action :find_person, only: [:show, :edit, :update, :destroy]

  def index
    render Demo::Pages::Persons::Index
  end

  def show
    render Demo::Pages::Persons::Show
  end

  def new
    render Demo::Pages::Persons::New
  end

  def create
    person = Person.create person_params
    if person.errors.empty?
      render json: { transition_to: person_path(person) }, status: :created
    else
      render json: { errors: person.errors }, status: :unprocessable_entity
    end
  end

  def edit
    render Demo::Pages::Persons::Edit
  end

  def update
    if @person.update person_params
      render json: { transition_to: person_path(@person) }, status: :ok
    else
      render json: { errors: @person.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @person.destroy
      render json: { transition_to: persons_path }, status: :ok
    else
      render json: { errors: @person.errors }, status: :unprocessable_entity
    end
  end

  protected

  def find_person
    @person = Person.find_by(id: params[:id])
  end

  def person_params
    params.require(:person).permit(
      :first_name,
      :last_name,
      :role
    )
  end

end
```

What's going on there? We've added `render`-calls for two new matestack pages (new, edit) and controller actions for create, update and destroy. To keep the code clean, we have extracted some functionality into a `before_action` and added the `person_params` method to extract person relevant params from all params in rails safe params manner.

Nothing extraordinary, but definitely stepping things up a bit!

## Adding the new and edit pages with forms

Create a new page in `app/matestack/demo/pages/persons/new.rb` and add the following content:

```ruby
class Demo::Pages::Persons::New < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All persons'
    heading size: 2, text: 'Create a new person'
    form new_person_form_config do
      label text: 'First name'
      form_input key: :first_name, type: :text
      br
      label text: 'Last name'
      form_input key: :last_name, type: :text
      br
      label text: 'Person role'
      form_radio key: :role, options: Person.roles.keys
      br
      form_submit do
        button text: 'Create person'
      end
    end
  end

  def new_person_form_config
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

What's going on here? Let's break it down:

Within our response method we have at first a transition to the person index page. After that comes _h2_ tag as a headline stating 'Create a new person'. Nothing new so long. Afterwards comes an unfamiliar call of `form`.

Let's take a closer look. Like in Rails with `form_for` you can create a form in matestack with `form`. It takes a hash as first argument for configuration. In this case we defined `new_person_form_config` to return the config hash for our form. In the config hash you can set the http request method, a path, success and failure configs and a for key, which will be explained soon. This form gets submitted as a POST request to the `persons_path`.

The `for` key let's us define for what this form is. In this case we pass a empty model to the form component, which will therefore submitt the form inputs wrapped by the model name following the Rails behavior and conventions.

The 'success' key let's us define a behavior when the form was submitted successful, which means the server returned a status code of 2XX. In this case we tell the form that if successful it should follow the transition path we return in our controller action. So a page transition will happen to the detail page of our newly created model. We could also configure a failure behavior by specifying the `failure` key.

Inside our form component we have calls to normal html components like `label, br, button` which render the corresponding html tag and we have calls for form inputs and a form submit. Let's take a closer look at the `form_input` call. A form input at least requires a key and a type. The type can be any html input type possible. The key defines the input name as which it will get submitted. If the model specified by the `for` key in the form config responds to the key the input will be prefilled with the value the model returns. `form_radio, form_select, form_checkbox` helpers can take an array or hash in the `options` key. They render for example a radio button for each option in the array or hash. In case of an array the label and value are the same for each radio button, in case of a hash the keys are used as labels and the values as values.
To enable the user to submit the form, we added a button to click. This button needs to be wrapped inside a `form_submit` call, which will take care of triggering the form submit if the contents inside the given block is clicked.

To learn more, check out the [complete API documentation](/docs/api/100-components/form.md) for the `form` component.

Take a moment to familiarize yourself with everything going on and then go ahead and create another page in `app/matestack/demo/pages/persons/edit.rb`, featuring similar content:

```ruby
class Demo::Pages::Persons::Edit < Matestack::Ui::Page

  def response
    transition path: :person_path, params: { id: @person.id }, text: 'Back to detail page'
    heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}"
    form person_edit_form_config do
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
        button text: 'Save changes'
      end
    end
  end

  def person_edit_form_config
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

Again, we're using a form within the `response` method and define its behaviour in the `person_edit_form_config`. Since this time, an existing person is looked up in the database, the form gets initialized with his/her data as described above.

## Updating the index page

Within the `response` block on the **Index** page (`app/matestack/demo/pages/persons/index.rb`), add the following line:

```ruby
transition path: :new_person_path, text: 'Create new person'
```

As you might have guessed, this takes us to the **New** page and you can create a new person there.

## Further introduction: Forms

During this article, you've got a general idea of how matestack forms handle data input. But since this is only an introductory guide, we can't cover all the possible use cases and functionality in here.

Let's do a quick recap: The `form` component can be used like other components we have seen before, but requires a hash as parameter for configuration. Within the hash, various configurations like HTTP method, submission path, payload and handling of success/failure responses can be set.

Beyond that, here's some suggestions of what you could try to add in the future:
- uploading files
- handling failure
- different input types like email, password, textfield, range or dropdown
- re-rendering parts of a page instead of doing a page transition
- using other Ruby objects than ActiveRecord collections
- fetching data from and sending data to third party APIs

To learn more, check out the [complete API documentation](/docs/api/100-components/form.md) for the `form` component.

## Adding a delete button for persons

We want to add the ability to delete persons. For that we add a delete button to the persons show page, which will destroy the person model when it was clicked. To achieve this we will use matestacks `action` component.

Update your show page in `app/matestack/demo/pages/persons/show.rb` to look like this:

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: persons_path, text: 'All persons'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"
    transition path: :edit_person_path, params: { id: @person.id }, text: 'Edit'
    action delete_person_config do
      button text: 'Delete person'
    end
  end

  def delete_person_config
    {
      method: :delete,
      path: person_path(@person),
      success: {
        transition: {
          follow_response: true
        }
      },
      confirm: {
        text: 'Do you really want to delete this person?'
      }
    }
  end

end
```

As you see we wrap our delete button inside an `action` component. Like the `form` component, an `action` component also takes a hash as first parameter for configuration. An action component triggers a asynchronous request when someone clicks on the wrapped content. The request target and http method are again configured in the hash. In this case when the action component is clicked it will send an DELETE request to `/persons/:id`. For a successful request we configured our `action` component to follow the redirect specified by the delete action. With the `confirm` keyword we can configure that when the button is clicked a confirm dialog pops up and needs to be confirmed before the request is send.

## Further introduction: Actions
As we've seen with the delete button, `matestack` actions are a convenient way to trigger HTTP requests without having to write a lot of code.

Let's do a quick recap: Similar to the `form`, an `action` component requires a hash as parameter for configuration and wraps other content, for example a button. This content is then clickable and triggers whatever HTTP request is specified in the configuration.

Beyond that, here's some suggestions of what you could try to add in the future:
- sending an advanced payload with the HTTP request
- re-rendering parts of a page on successful request

To learn more, check out the [complete API documentation](/docs/api/100-components/action.md) for the `action` component.

## Local testing

Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to test the changes! You should be able to create new persons as well as edit and delete existing ones!

## Saving the status quo

As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Add edit/new matestack pages for person model (incl. create/update controller, routes), add delete button (incl. controller action & route) to person show page"
```

## Recap & outlook

By now, we have already implemented the complete **CRUD** (**C**reate-**R**ead-**U**pdate-**D**elete) functionality around the person model. Neat!

We got a brief introduction of the `form` and `action` components and know how to use them.

But there's still more guides coming - so what's left? In the upcoming chapters, we will dive deeper into some `matestack` concepts to further enhance both user experience and developer happiness!

Take a well deserved rest and make sure to come back to the next part of this series, introducing the powerful [`toggle component`](/docs/guides/100-tutorial/05_toggle_component.md).
