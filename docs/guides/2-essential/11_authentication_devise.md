# Essential Guide 11: Authentication

Welcome to the eleventh part of our essential guide about building a web application with matestack.

## Introduction

Our app looks great after finishing the [previous guide](/docs/guides/2-essential/10_styling_notifications.md). To make it more of a real-world example, we add a private area, which is only accessible for logged in admins.

In this guide, we will
- install and set up the devise gem
- add a second matestack app for our private administration area
- move some of the CRUD functionality into the private admin app
- add a link to the administration area in our demo app

## Prerequisites

We expect you to have successfully finished the [previous guide](/docs/guides/2-essential/10_styling_notifications.md).

## Setting up Devise

For authentication we use the popular library [devise](https://github.com/heartcombo/devise). To install it, we add `gem 'devise'` to our Gemfile and run `bundle install` afterwards.
To finish the devise installation we run `rails generate devise:install`.

Then we need to add 

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

in `config/environments/development.rb`.

## Generating our admin model

After a successful setup we can now generate our admin model. Our admins don't need any extra data, so it's enough to run devise generator and specify admin as a name for our model.

```sh
rails generate devise admin
```

Finally, we need to migrate the database by running

```sh
rails db:migrate
```

and save our changes to Git via

```sh
git . && git commit -m "add devise and create admin model"
```

## Adding admin app, controllers and routes
Our demo app is responsible for all pages available to everyone, but some actions should only be available by admins. This is one reason to create a seperate admin app. The other reason is that we want another layout for our admin app. Therefore we create a second matestack app under the `Admin` namespace in `app/matestack/admin/app.rb`.

```ruby
class Admin::App < Matestack::Ui::App

  def response
    navigation
    notifications
    main id: 'page-content' do
      yield_page slots: { loading_state: loading_state_element }
    end
    footer
  end

  private

  def navigation
    nav class: 'navbar navbar-expand-md navbar-dark bg-dark fixed-top' do
      transition class: 'navbar-brand font-weight-bold', path: root_path, text: 'AdminApp', delay: 300
      if admin_signed_in?
        navbar_toggle_button
        div id: 'navbar', class: 'collapse navbar-collapse justify-content-end' do
          div class: 'w-100' do
            navbar_right
          end
          navbar_left
        end
      end
    end
  end

  def navbar_toggle_button
    button class: 'navbar-toggler', attributes: { 
      "data-target": "#navbar", role:"button", "data-toggle": "collapse", 
      "aria-controls": "navbar", "aria-expanded": "false" 
    } do
      span class: 'navbar-toggler-icon'
    end
  end

  def navbar_right
    ul class: 'navbar-nav mr-0' do
      li class: 'nav-item' do
        transition class: 'nav-link text-light', path: admin_persons_path, text: 'All persons', delay: 300
      end
    end
  end

  def navbar_left
    ul class: 'navbar-nav mr-0' do
      li class: 'nav-item' do
        link class: 'nav-link text-light mr-3', path: persons_path, text: 'Demo App', delay: 300
      end
      li class: 'nav-item' do
        action logout_action_config do
          span class: 'btn-nav btn btn-primary', text: I18n.t('devise.sessions.logout')
        end
      end
    end
  end

  def loading_state_element
    slot do
      div id: 'spinner', class: 'spinner-border', role: 'status' do
        span class: 'sr-only', text: 'Loading...'
      end
    end
  end

  def footer
    div class: 'jumbotron jumbotron-fluid bg-dark mb-0 footer' do
      div class: 'container py-5' do
        div class: 'd-flex align-items-center justify-content-center' do
          heading class: 'm-0 mr-1 font-weight-normal text-light', size: 5, 
            text: 'This demo application and corresponding guides are provided by'
          img path: asset_path('matestack'), height: '48px'
        end
      end
    end
  end

  def logout_action_config
    {
      method: :delete,
      path: destroy_admin_session_path,
      success: {
        redirect: {
          follow_response: true
        }
      }
    }
  end

end

```

In our `Admin::App` we call a custom `notifications` component which we will now create under `app/matestack/admin/components/notifications.rb`. Why do we this time put our components folder inside our admin folder? Because the notifications component should only be used in the admin context and we therefore store components that should only be used in the admin context inside the admin folder. We even create another registry in `app/matestack/admin/components/registry.rb` to seperate the two contexts better.

```ruby
module Admin::Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    notifications: Admin::Components::Notifications
  )

end
```

```ruby
class Admin::Components::Shared::Notifications < Matestack::Ui::Component

  def response
    div class: 'alert-wrapper' do
      # alerts for different events will be added later here
    end
  end

end
```

While it's similar to the `Demo::App`, the `Admin::App` does have some differences. Notice how we hide a part of the navigation if no admin is currently signed in, making use of a `Devise` helper: 

```ruby
if admin_signed_in?
```

There is also a logout button, using an `action` compoent.

We could now use the `Admin::App` as layout, but we need to set it with `matestack_app` in the corresponding controller and we need to include our new registry with `include Admin::Component::Registry`. 

Let's create our routes for our admin area and after it the controllers we referred to in our routes.

```ruby
devise_for :admins

namespace :admin do
  root to: 'persons#index'
  resources :persons, except: [:show]
end
```

`app/matestack/controllers/admin/persons_controller.rb`
```ruby
class Admin::PersonsController < ApplicationController
  include Admin::Components::Registry

  matestack_app Admin::App

end
```

Notice the include of our registry and the call for setting our matestack app. Now that we have our admin persons controller and admin app we can create our different pages.

## Admin persons index, edit, new pages

First we create an index page in `app/matestack/admin/pages/persons/index.rb`, which shows all persons in a table. To implement it we use the `collection` component.

```ruby
class Admin::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    person_collection_id = "persons-collection"
    current_filter = get_collection_filter(person_collection_id)
    person_query = Person.all.order(id: :asc)
    filtered_person_query = person_query
      .where("last_name LIKE ?", "%#{current_filter[:last_name]}%")
    @person_collection = set_collection({
      id: person_collection_id,
      data: filtered_person_query,
			init_limit: 10,
			filtered_count: filtered_person_query.count,
			base_count: person_query.count
    })
  end

  def response
    div class: 'container my-5' do
      div class: 'text-right' do 
        transition class: 'btn btn-success mb-3', text: '+ New person', path: new_admin_person_path, delay: 300
      end
      filter
      async id: 'collection', rerender_on: 'persons-collection-update' do 
        collection_content @person_collection.config do
          table class: 'table table-striped table-light table-hover mt-3' do
            table_head
            table_body
          end
          paginator
        end
      end
    end
  end

  private

  def filter
    collection_filter @person_collection.config do
      div class: 'd-flex' do
        collection_filter_input key: :last_name, type: :text, placeholder: 'Filter by Last name', class: 'form-control'
        collection_filter_submit do
          button class: 'btn btn-outline-primary ml-1', text: 'Apply'
        end
        collection_filter_reset do
          button class: 'btn btn-outline-secondary ml-1', text: 'Reset'
        end
      end
    end
  end

  def table_head
    tr do
      th text: '#'
      th text: 'Last name'
      th text: 'First name'
      th text: 'Role'
      th
    end
  end

  def table_body
    @person_collection.paginated_data.each do |person|
      tr do
        td text: person.id
        td do
          transition path: edit_admin_person_path(person), text: person.last_name, class: 'text-dark font-weight-bold', delay: 300
        end
        td text: person.first_name
        td text: person.role
        td class: 'text-right' do
          action delete_person_config(person) do
            button text: 'Delete', class: 'btn btn-outline-primary'
          end
        end
      end
    end
  end

  def paginator
    ul class: 'pagination justify-content-center' do
      li class: 'page-item' do
        collection_content_previous do
          button class: 'page-link', text: 'previous'
        end
      end
      @person_collection.pages.each do |page|
        li class: 'page-item' do
          collection_content_page_link page: page do
            button class: 'page-link', text: page
          end
        end
      end
      li class: 'page-item' do
        collection_content_next do
          button class: 'page-link', text: 'next'
        end
      end
    end
  end


  def delete_person_config(person)
    {
      method: :delete,
      path: admin_person_path(person),
      success: {
        emit: 'persons-collection-update'
      },
      confirm: {
        text: "Do you really want to delete '#{person.first_name} #{person.last_name}'?"
      }
    }
  end

end
```

Now we create the new and edit pages. Like we did earlier in our demo page, we create a form page which will contain a form partial, because both views will use the same view. By excluding it in a partial in a form page, both new and edit can inherit from it and reuse our form. 

`app/matestack/pages/persons/form.rb`
```ruby
class Admin::Pages::Persons::Form < Matestack::Ui::Page

  protected

  def person_form(save_button)
    form person_form_config, :include do
      form_group label: 'First name:' do
        form_input key: :first_name, class: 'form-control', type: :text
      end
      form_group label: 'Last name:' do
        form_input key: :last_name, class: 'form-control', type: :text
      end
      form_group label: 'Last name:' do
        form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys
      end
      transition path: admin_persons_path, class: 'btn btn-secondary my-3', text: 'Cancel', delay: 300
      form_submit do
        button class: 'btn btn-primary', text: save_button
      end
    end
  end

  def person_form_config
    raise 'implement in inheriting class'
  end

  def form_group(label: '', &block)
    div class: 'form-group row' do
      label class: 'col-sm-4 col-form-label col-form-label-md', text: label
      div class: 'col-sm-8' do
        yield
      end
    end
  end

end
```

Take a closer look at the form group partial here. Every form element has the same wrapping elements and the same label with its classes. In order to not repeat ourselfs and write less code we can use a partial, which takes a label text and a block and renders the wrapping elements, label and yields the block. Our form code therefore looks much cleaner now and we kept it DRY (don't repeat yourself).

`app/matestack/pages/persons/new.rb`
```ruby
class Admin::Pages::Persons::New < Admin::Pages::Persons::Form

  def prepare
    @person = Person.new
  end

  def response
    div class: 'container' do
      div class: 'row' do
        div class: 'col-md-6 offset-md-3 text-center' do
          heading size: 2, text: 'Create new person', class: 'my-3'
          person_form 'Create'
        end
      end
    end
  end

  def person_form_config
    {
      for: @person,
      method: :post,
      path: :admin_persons_path,
      success: {
        emit: 'person_form_success',
        transition: {
          follow_response: true,
          delay: 300
        }
      },
      failure: {
        emit: 'person_form_failure'
      }
    }
  end

end
```
`app/matestack/pages/persons/edit.rb`
```ruby
class Admin::Pages::Persons::Edit < Admin::Pages::Persons::Form

  def response
    div class: 'container my-5' do
      div class: 'row' do
        div class: 'col-md-6 offset-md-3 text-center' do
          heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}", class: 'my-3'
          person_form 'Save changes'
        end
      end
    end
  end

  def person_form_config
    {
      for: @person,
      method: :patch,
      path: admin_person_path(@person),
      success: {
        emit: 'person_form_success'
      },
      failure: {
        emit: 'person_form_failure'
      }
    }
  end

end
```

Nothing special for our new and edit page. Both inheriting from the form page, overwriting the form config and using the form partial.

With the pages we added the possibility to maintain the persons as admin, by editing, deleting existing ones or creating new ones.

But we still need a login page. Go ahead and add it in `app/matestack/admin/pages/sessions/sign_in.rb` with this content:

```ruby
class Admin::Pages::Sessions::SignIn < Matestack::Ui::Page

  def response
    div class: 'container my-5' do
      div class: 'row' do
        div class: 'col-md-4 offset-md-4' do
          div class: 'card' do
            div class: 'card-body text-center' do
              heading text: t('devise.sessions.new.login')
              login_form
            end
          end
        end
      end
    end
  end

  private

  def login_form
    form form_config, :include do
      form_group label: 'E-Mail'  do
        form_input key: :email, type: :text
      end
      form_group label: 'Password' do
        form_input key: :password, type: :password
      end
      form_submit class: 'text-center d-block' do
        button class: 'btn btn-primary text-center', text: 'Login'
      end
    end
  end

  def form_group(label: '', &block)
    div class: 'form-group row' do
        label class: 'col-sm-12 col-form-label col-form-label-md', text: label
        div class: 'col-sm-12' do
          yield
        end
      end
  end

  def form_config
    {
      for: :admin,
      method: :post,
      path: admin_session_path,
      success: { 
        redirect: { 
          follow_response: true 
        } 
      },
      failure: { 
        emit: "login_failure" 
      }
    }
  end

end
```

### Admin Controllers

Now that we have our pages, we will need to update our persons controller

Update it accordingly:

```ruby
class Admin::PersonsController < Admin::BaseController

  matestack_app Admin::App
  before_action :find_person, only: [:show, :edit, :update, :destroy]

  def new
    render Admin::Pages::Persons::New
  end

  def index
    render Admin::Pages::Persons::Index
  end

  def edit
    render Admin::Pages::Persons::Edit
  end

  def update
    if @person.update person_params
      render json: { }, status: :ok
    else
      render json: { errors: @person.errors }, status: :unprocessable_entity
    end
  end

  def create
    person = Person.create(person_params)
    if person.valid?
      render json: { transition_to: edit_admin_person_path(person) }, status: :created
    else
      render json: { errors: person.errors }, status: :unprocessable_entity
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

  def find_person
    @person = Person.find_by(id: params[:id])
  end

  def person_params
    params.require(:person).permit(
      :first_name,
      :last_name,
      :active,
      :role
    )
  end

end
```

We added all required actions according to our routes. Did you notice our controller now inherits from a `Admin::BaseController`? We need to create it in the next step, but why did we create one? Because all routes and corresponding actions belonging to the admin should not be visible without logging in as admin. Therefore we implement a `before_action` hook which calls devise `authenticate_admin!` helper, making sure that every action can only be called by a logged in admin. We could do this in our persons controller, but as we might add other controllers later they only need to inherit from our base controller and are also protected. Let's create the base controller in `app/controllers/admin/base_controller.rb`.

```ruby
class Admin::BaseController < ApplicationController
  include Admin::Components::Registry

  layout 'administration'
  before_action :authenticate_admin!
end
```

In order for devise to use our sign in page, we need to create a custom session controller. Also we need to override the create and delete action of devise session controller, because we would else get errors or unwanted behavior. If we don't override the `create` action devise will trigger a full website reload and rerendering our sign in page, which means we couldn't handle login errors dynamically. The `delete` action needs to be overriden because devise usual redirect will not work with matestack. See below on how to create the session controller for devise and don't forget to update the routes in order to tell devise to use the correct controller.


`app/controllers/admin/sessions_controller.rb`
```ruby
class Admin::SessionsController < Devise::SessionsController
  include Admin::Components::Registry
  
  matestack_app Admin::App
  layout 'administration'

  def new
    render Admin::Pages::Sessions::SignIn
  end

  def create
    self.resource = warden.authenticate(auth_options)
    return render json: {}, status: 401 unless resource
    sign_in(resource_name, resource)
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    redirect_to new_admin_session_path, status: :see_other #https://api.rubyonrails.org/classes/ActionController/Redirecting.html
  end

end
```

`config/routes.rb`
```ruby
Rails.application.routes.draw do
  root to: 'persons#index'

  get '/first_page', to: 'demo#first_page'
  get '/second_page', to: 'demo#second_page'

  resources :persons

  devise_for :admins, controllers: {
    sessions: 'admin/sessions'
  }

  namespace :admin do
    root to: 'persons#index'
    resources :persons
  end

end
```

But if you try to start your application locally, visiting the admin pages doesn't work yet - what's going on?

### Styling, Layout & JavaScript

Notice that we added `layout 'administration'` inside our admin controllers. This looks for file called `administration.html.erb` in `app/views/layouts/`, which we need to create. Add the following content to it:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <title>MatestackDemoApplication</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_pack_tag 'administration', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'administration', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div id="matestack-ui">
      <%= yield %>
    </div>
  </body>
</html>
```

In there, we reference a different `javascript_pack_tag`(that is, `'administration'`) than in our `application.html.erb` layout (which uses `'application'`) - so we need to set it up via Webpacker!

Add a new file in `app/javascript/packs/administration.js`, with the following content:

```js
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import 'css/custom-admin-bootstrap'
import 'css/application'
import 'css/page-transition'

import 'jquery'
import 'popper.js'
import 'bootstrap'

import MatestackUiCore from 'matestack-ui-core'
```

When you compare it to `app/javascript/packs/application.js` which sits right next to it, you will see that the two diverge in one point: The admin pack imports `'css/custom-admin-bootstrap'`, so we need to create it.

Here's the `custom-admin-bootstrap.scss` which you need to add in `app/javascript/css/`. It looks very familiar because it is. There's not much difference between it and our `custom-bootstrap.scss`. But we may want to theme our admin app differently than our demo app, so in case we can by just changing the colors in this file for example.

```css
$darkest-orange: #FF3B14;
$light-orange: #fecdc3;

$lightest-grey: #F4F4F5;
$dark-grey: #A4A4AE;
$darkest-grey: #1B1D35;

$darkest-blue: #1b1d35;
$darker-blue:#606171;

$body-bg: white;
$body-color: $darkest-grey;

$theme-colors: (
  "primary": $darkest-orange,
  "secondary": $darker-blue,
  "info": $light-orange,
  "warning": $dark-grey,
  "dark": $darkest-blue,
  "light": $lightest-grey,
);

@import "~bootstrap/scss/bootstrap.scss";

.alert-wrapper {
  max-width: 300px;
  position: fixed !important;
  top: 4.5rem;
  right: 1rem;
}
```

## Updating the notifications component

As you might saw or experienced, our admin person edit page doesn't really do anything if we update a user. Thats because we have no show page to which we would normally transition. If we transition to the edit page, you wouldn't see any difference and therefore will not know if the update was successfull. Here comes our notification component in handy. We will implement bootstrap alerts popping up showing success or failure messages by using the `toggle` component in combination with the form `success: { emit: '...' }` and `failure: { emit: '...' }` configuration options. As you can see above we emit a `person_form_success` or `person_form_failure` in our edit and new forms depending on the result. We
therefore can use a `toggle` component with these events. Let's update our notification component to do that.

```ruby
class Admin::Components::Shared::Notifications < Matestack::Ui::Component

  def response
    div class: 'alert-wrapper' do
      # alerts for new and edit person forms
      notification_badge :person_form_success, :success, 'Person successfully updated'
      notification_badge :person_form_failure, :danger, 'There was an error while saving the person.'
      
      # alerts for login
      notification_badge :login_failure, :danger, 'Login incorrect'
    end
  end

  private

  def notification_badge(event, type, message)
    toggle show_on: event, hide_after: 3000 do
      div class: "alert alert-#{type} alert-dismissible" do
        plain message
        button class: 'close', attributes: { 'data-dismiss': :alert, 'aria-label': 'Close' } do
          span text: '&times;'.html_safe
        end
      end
    end
  end

end
```

We again created a partial which will take a few parameters and a block in order to wrapp the block inside a bootstrap alert. We use a `toggle` component with `show_on` to display the alert when the corresponding event is triggered and use `hide_after` to hide it after a 3000ms automatically. The `.alert-wrapper` was styled so it appears in the right corner beneath the navigation.

When we now edit a user we will see an alert in the corner communicating the status of the update.

We also added a notification for our earlier defined `login_failure` event of our sign in page in order to communicate a failed login attempt.

## Reducing functionality in the DemoApp and adding an admin login link

After creating the `Admin::App`, let's cut some functionality from the `Demo::App` and make it exclusively available to a logged-in admin!

Remove the following lines from both `app/matestack/demo/pages/edit.rb` and `app/matestack/demo/pages/new.rb`:

```ruby
div class: 'form-group row' do
  label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Person role:'
  div class: 'col-sm-8' do
    # edit.rb
    form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: @person.role
    # new.rb
    form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: Person.roles.keys.first
  end
end
```

Also, remove `:role` from the `person_params` in `app/controllers/persons_controller.rb` - if we forget to do that, a sophisticated, not-logged-in user still could edit roles through sending requests directly to our backend!

Since any page visitor can now create new person records in the database but only admins can edit the `:role` attribute, let's add a default value through a migration:

```sh
rails g migration AddDefaultToPersonRole
```

Changing the default is quite straightforward:

```ruby
class AddDefaultToPersonRole < ActiveRecord::Migration[6.0]
  def change
    change_column_default :person, :role, from: nil, to: 0
  end
end
```

And, to make it work, we need to migrate the database by running

```sh
rake db:migrate
```

Finally, add a link to the `sign_in` page to the `navigation` partial in `app/matestack/demo/app.rb`:

```ruby
  def navigation
    nav class: 'navbar navbar-expand-md navbar-light bg-white fixed-top' do
      transition class: 'navbar-brand font-weight-bold text-primary', path: root_path, text: 'DemoApp', delay: 300
      navbar_button
      div id: 'navbar-default', class: 'collapse navbar-collapse' do
        ul class: 'navbar-nav mr-auto' do
          li class: 'nav-item' do
            transition class: 'nav-link text-dark', path: persons_path, text: 'Persons', delay: 300
          end
          li class: 'nav-item' do
            transition class: 'nav-link text-dark', path: new_person_path, text: 'New', delay: 300
          end
          li class: 'nav-item' do
            link class: 'nav-link text-secondary', path: new_admin_session_path, text: 'Login'
          end
        end
      end
    end
  end
```

To finish things off, let's add the recent changes to Git via

```sh
git add app/controllers/persons_controller.rb app/matestack/demo/app.rb app/matestack/demo/pages/ db/
```

and commit them by running

```sh
git commit -m "Add admin login to DemoApp, add default :role to Person model, restrict role modification to admins"
```

## More information on Devise & Matestack

What exactly is going on under the hood with all the admin sign in stuff, you may wonder?

Here's a quick overview: Instead over implementing loads of (complex) functionality with a load of implications and edge cases, we use the `Devise` gem for a rock-solid authentication. It takes care of hashing, salting and storing the password, and through the `Devise::SessionsController`, of managing the session cookie. All that's left for us to do is check for the existence of said cookie by using the `authenticate_admin!` helper. If the required cookie is not present, the controller responds with an error code.

`Devise` could do a lot more, but as this is a basic guide, we will leave it with that. For even more fine-grained control over access rights (authorization) within your application (e.g. by introducing a superadmin or having regional and national manager roles), we recommend to take a look at two other popular Ruby/Rails gems, [Pundit](https://github.com/varvet/pundit) and [CanCanCan](https://github.com/CanCanCommunity/cancancan).

## Creating a admin

In order to use the admin app we need to create an admin with credentials which we can now use to sign in.

```ruby
a = Admin.create(email: 'admin@example.com', password: 'OnlyForSuperMates', password_confirmation: 'OnlyForSuperMates')
```

## Recap & outlook

By adding a working authentication functionality and an admin app protected via a login, our project now much better resembles a real-world software application! On the way, we covered some advanced topics like authentication via the `Devise` gem, serving different JavaScript packs using `Webpacker` and Rails `layouts`. We leared how to structure components and pages with different namespaces and how to use different registries.

While the application is good as it is right now, go ahead and check out the [next part of this guide](/docs/guides/2-essential/12_wrap_up.md).
