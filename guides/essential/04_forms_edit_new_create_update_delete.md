# Essential Guide 4: Forms & Actions (Create, Update, Delete)
Welcome to the forth part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In the [previous guide](guides/essential/03_index_show_transition.md), we added index and show pages for the **person** model. In this part, we will add the functionality to add new instances and edit and delete our database records using `matestack` forms.

In this guide, we will
- add a **New** page and corresponding controller action to create new persons
- add an **Edit** page and corresponding controller action to modify existing persons
- add an action with a delete button to the "show" page and corresponding controller action to remove an existing person from the database
- introduce the concept of `matestack` forms
- introduce the concept of `matestack` actions

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/03_index_show_transition.md) and no uncommited changes in your project.

## Updating the person model
Let's make sure all the persons in our database actually end up having a name and a a role by adding those lines to `app/models/person.rb`:

```ruby
validates :first_name, presence: true
validates :last_name, presence: true
validates :role, presence: true
```

This might not seem like a big change, but will help with validating form input later on!

## Preparing routes & controller
In your `config/routes.rb`, change

```ruby
resources :persons, only: [:index, :show]
```

to

```ruby
resources :persons
```

to allow further actions for the ressource.

Then, in the `persons_controller.rb`, update the contents like this:

```ruby
class PersonsController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  matestack_app Demo::App

  def new
    render Demo::Pages::Persons::New)
  end

  def index
    render Demo::Pages::Persons::Index)
  end

  def show
    render Demo::Pages::Persons::Show)
  end

  def edit
    render Demo::Pages::Persons::Edit)
  end

  def update
    @person.update person_params

    @person.save
    if @person.errors.any?
      render json: {errors: @person.errors}, status: :unprocessable_entity
    else
      render json: { transition_to: person_path(id: @person.id) }, status: :ok
    end
  end

  def create
    @person = Person.new(person_params)
    @person.save

    if @person.errors.any?
      render json: {errors: @person.errors}, status: :unprocessable_entity
    else
      render json: { transition_to: person_path(id: @person.id) }, status: :created
    end
  end

  def destroy
    if @person.destroy
      render json: { transition_to: persons_path }, status: :ok
    else
      render json: {errors: @person.errors}, status: :unprocessable_entity
    end
  end

  protected

  def set_person
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

What's going on there? We've added `render`-methods for two new `matestack` pages (**New** and **Edit**) and controller endpoints for **create**, **update** and **destroy** actions. Since we're interacting with the database directly now, we also need to sanitize the params and, to keep the code clean, have extracted some functionality into a `before_action`.

Nothing extraordinary, but definitely stepping things up a bit!

## Adding the **New** and **Edit** pages
Create a new page in `app/matestack/demo/pages/persons/new.rb` and add the following content:

```ruby
class Demo::Pages::Persons::New < Matestack::Ui::Page

  def prepare
    @person = Person.new
  end

  def response
    transition path: :persons_path, text: 'Back to index page'
    heading size: 2, text: 'Create new person'
    form new_person_form_config, :include do
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
        button text: 'Create person'
      end
    end
  end

  def new_person_form_config
    {
      for: @person,
      method: :post,
      path: :persons_path,
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
- in the `prepare` method, an empty person record is created so we can fill it later
- within the `response` method, there's a link back to the **Show** page, a heading and the first `matestack` form, featuring two text input fields, radio select fields and a submit button
- the `new_person_form_config` tells the form which data to use (the empty person, in this case), where to send the inputs upon submission and how to handle successful (and, potentially, unsuccessful) response messages from the controller!

Take a moment to familiarize yourself with everything going on in the file, and then go ahead and create another page in `app/matestack/demo/pages/persons/edit.rb`, featuring similar content:

```ruby
class Demo::Pages::Persons::Edit < Matestack::Ui::Page

  def response
    transition path: :person_path, params: { id: @person.id }, text: 'Back to detail page'
    heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}"
    form person_edit_form_config, :include do
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

Again, we're using a form within the `response` method and define its behaviour in the `person_edit_form_config`. Since this time, an existing person is looked up in the database, the form gets initialized with his/her data.

## Updating the **Index** page
Within the `response` block on the **Index** page (`app/matestack/demo/pages/persons/index.rb`), add the following line:

```ruby
transition path: :new_person_path, text: 'Create new person'
```

As you might have guessed, this takes us to the **New** page and you can add a new person to the database there!

## Adding the **delete** button to the **Show** page
Update your **Show** page in `app/matestack/demo/pages/persons/show.rb` to look like this:

```ruby
class Demo::Pages::Persons::Show < Matestack::Ui::Page

  def response
    transition path: :persons_path, text: 'Back to index'
    heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
    paragraph text: "Role: #{@person.role}"
    transition path: :edit_person_path, params: { id: @person.id }, text: 'Edit'
    action delete_person_config do
      button text: 'Delete person'
    end
  end

  def delete_person_config
    return {
      method: :delete,
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

This is the first time we encounter another powerful `matestack` component: The `action` component! In the example above, the delete button gets wrapped into an `action` that receives a `*_config*` parameter. The configuration then is specified below, sending the currently displayed person's `id` to the **delete** action in the `person controller`. Upon a positive response from our controller, we configure our `action` component to follow the redirect specified in the **delete** action.

## Further introduction: Forms
During this article, you've got a general idea of how `matestack` forms handle data input. But since this is only an introductory guide, we can't cover all the possible use cases and functionality in here.

Let's do a quick recap: The `form` component can be used like the other components we have seen before, but requires a `*_config` parameter. Within the `*_config`, various parameters like HTTP method, submission path, payload and handling of success/error responses can be set.

Beyond that, here's some suggestions of what you could try to add in the future:
- uploading files
- handling failure
- different input types like email, password, textfield, range or dropdown
- re-rendering parts of a page instead of doing a page transition
- using other Ruby objects than ActiveRecord collections
- fetching data from and sending data to third party APIs instead of interacting with your database

To learn more, check out the [complete API documentation](docs/components/form.md) for the `form` component.

## Further introduction: Actions
As we've seen with the delete button, `matestack` actions are a convenient way to trigger HTTP requests without having to write a lot of code.

Let's do a quick recap: Similar to the `form`, an `action` component requires a `*_config` parameter and wraps other content, for example a button. This content is then clickable and triggers whatever HTTP request is specified in the configuration.

Beyond that, here's some suggestions of what you could try to add in the future:
- sending an advanced payload with the HTTP request
- adding a confirmation window
- re-rendering parts of a page on successful request

To learn more, check out the [complete API documentation](docs/components/action.md) for the `action` component.

## Local testing
Run `rails s` and head over to [localhost:3000](http://localhost:3000/) to test the changes! You should be able to create new persons as well as edit and delete existing ones!

## Saving the status quo
As usual, we want to commit the progress to Git. In the repo root, run

```sh
git add . && git commit -m "Add edit/new matestack pages for person model (incl. create/update controller, routes), add delete button (incl. controller action & route) to person show page"
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

and celebrate your progress by creating some new persons, modifying existing ones and delete one or two!

## Recap & outlook
By now, we have already implemented the complete **CRUD** (**C**reate-**R**ead-**U**pdate-**D**elete) functionality around the person model. Neat!

But there's still six out of ten guides open - so what's left? In the upcoming chapters, we will dive deeper into some `matestack` concepts to further enhance both user experience and developer happiness!

Take a well deserved rest and make sure to come back to the next part of this series, introducing the powerful [`async` and `collection` components](/guides/essential/04_form_create_update_delete.md).
