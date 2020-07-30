# Essential Guide 9: Authentication
Welcome to the ninth part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
Our app works good and looks great after finishing the [previous guide](guides/essential/08_styling_notifications.md). To make it more of a real-world example, let's add some functionality so admins can log in and restrict some of the possible user interaction to logged-in admins!

In this guide, we will
- install and set up the `Devise` gem
- add a second `matestack` app for administrators
- create Controllers&Pages so the **AdminApp** can perform CRUD actions
- remove some actions from the **DemoApp** and add a link to the admin login

## Prerequisites
We expect you to have successfully finished the [previous guide](guides/essential/08_styling_notifications.md) and no uncommited changes in your project.

## Setting up Devise
For authentication, we rely on a popular library called [Devise](https://github.com/heartcombo/devise). You can install it by adding it to the `Gemfile` as

```ruby
gem 'devise'
```

Then run

```sh
bundle install && rails generate devise:install
```

to install it and set it up. Afterwards, you need to add 

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

somewhere in `config/environments/development.rb` to enable the `Devise` mailer functionality.

Let's go ahead and generate our admin model by making use of a `Devise` helper: 

```sh
rails generate devise admin
```

Finally, we need to migrate the database by running

```sh
rails db:migrate
```

and save our changes to Git via

```sh
git add Gemfile Gemfile.lock app/models/admin.rb config/ db/ test/ && git commit -m "Add devise and create admin model"
```

## Adding admin app, pages, controllers & routes
To properly separate the pages we want to hide behind our login from the ones in the `Demo::App`, we create a second `matestack` app called `Admin::App` in `app/matestack/admin/app.rb`:

```ruby
class Admin::App < Matestack::Ui::App

  def response
    partial :navigation if admin_signed_in?
    div id: 'spinner', class: 'spinner-border', role: 'status' do
      span class: 'sr-only', text: 'Loading...'
    end
    main id: 'page-content' do
      page_content
    end
  end

  def navigation
    header do
      nav class: 'navbar navbar-expand-md navbar-dark bg-dark fixed-top' do
        transition class: 'navbar-brand', path: :root_path, text: 'AdminApp'
        button class: 'navbar-toggler', attributes: { "data-target": "#navbarsExampleDefault", role:"button", "data-toggle": "collapse", "aria-controls": "navbarsExampleDefault", "aria-expanded": "false" } do
          span class: 'navbar-toggler-icon'
        end
        div id: 'navbarsExampleDefault', class: 'collapse navbar-collapse justify-content-end' do
          ul class: 'navbar-nav mr-0' do
            li class: 'nav-item' do
              transition class: 'nav-link', path: :persons_path, text: 'All persons'
            end
            li class: 'nav-item' do
              action logout_action_config do
                span class: 'btn-nav btn btn-primary', text: I18n.t('devise.sessions.logout')
              end
            end
          end
        end
      end
    end
  end

  protected

  def logout_action_config
    {
      method: :delete,
      path: :destroy_admin_session_path,
      success: {
        emit: "reload_page",
        transition: {
          follow_response: true
        }
      }
    }
  end

end
```

While it's similar to the `Demo::App`, the `Admin::App` does have some differences. Notice how we hide the navigation if no admin is currently signed, making use of a `Devise` helper: 

```ruby
partial :navigation if admin_signed_in?
```

There is also a logout button, using a `matestack` action in a similar way to what we have seen before. This time, performing the action emits an event (`emit: "reload_page"`) which we will take care of later in this article.

The `Admin::App` now provides us with a layout, but it does not feature any pages yet. To change that, create a new folder in `app/matestack/admin/pages/persons/` and add the following four pages, quite similiar to the ones in the `DemoApp`:

```ruby
# app/matestack/admin/pages/persons/index.rb
class Admin::Pages::Persons::Index < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    person_collection_id = "person-collection"

    current_filter = get_collection_filter(person_collection_id)
		current_order = get_collection_order(person_collection_id)

		person_query = Person.all

    filtered_person_query = person_query
    .where("last_name LIKE ?", "%#{current_filter[:last_name]}%")
		.order(current_order)

    @person_collection = set_collection({
      id: person_collection_id,
      data: filtered_person_query,
			init_limit: 3,
			filtered_count: filtered_person_query.count,
			base_count: person_query.count
    })
  end

  def response
    section id: 'persons-filter-order' do
      div class: 'container' do
        div class: 'row' do
          div class: 'offset-md-1 col-md-5' do
            partial :filter
          end
          div class: 'col-md-5' do
            partial :ordering
          end
        end
      end
    end

    section id: 'persons-collection' do
      div class: 'container' do
        async rerender_on: 'person-collection-update' do
          partial :content
        end
      end
    end
  end

  def filter
    collection_filter @person_collection.config do
      collection_filter_input key: :last_name, type: :text, placeholder: 'Filter by Last name'
      collection_filter_submit do
        button class: 'btn btn-primary', text: 'Apply'
      end
      collection_filter_reset do
        button class: 'btn btn-primary', text: 'Reset'
      end
    end
  end

	def ordering
    collection_order @person_collection.config do
      plain 'Sorted by:'
      collection_order_toggle key: :last_name do
        button class: 'btn btn-primary' do
          collection_order_toggle_indicator key: :last_name, asc: 'Last name (A-Z)', desc: 'Last name (Z-A)', default: 'Date of creation'
        end
      end
    end
	end

  def content
    collection_content @person_collection.config do
      div class: 'row' do
        @person_collection.paginated_data.each do |person|
          div class: 'col-md-4' do
            person_card person: person, path: :admin_person_path
          end
        end
        div class: 'col-md-12 text-center my-3' do
          transition path: :new_admin_person_path, class: 'my-3 btn btn-info', text: 'Create new person'
        end
        partial :paginator
      end
    end
  end

	def paginator
    div class: 'container' do
      div class: 'row' do
        div class: 'col-md-12 text-center mt-5' do
          plain "Showing persons #{@person_collection.from}"
          plain "to #{@person_collection.to}"
          plain "of #{@person_collection.filtered_count}"
          plain "from a total of #{@person_collection.base_count} records."
          ul class: 'pagination' do
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
      end
    end
	end

end


# app/matestack/admin/pages/persons/show.rb
class Admin::Pages::Persons::Show < Matestack::Ui::Page

  def prepare
    @other_persons = Person.where.not(id: @person.id).order("RANDOM()").limit(3)
  end

  def response
    section do
      div class: 'container' do
        transition path: :persons_path, class: 'btn btn-secondary', text: 'Back to index'

        div class: 'row' do
          div class: 'col-md-6 offset-md-3 text-center' do
            heading size: 2, text: "Name: #{@person.first_name} #{@person.last_name}"
            paragraph text: "Role: #{@person.role}"
            transition path: :edit_admin_person_path, params: { id: @person.id }, class: 'btn btn-secondary', text: 'Edit'
            action delete_person_config do
              button class: 'btn btn-warning', text: 'Delete person'
            end
          end
        end
      end
    end

    partial :other_persons
    custom_person_activity
  end

  def other_persons
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-12 text-center' do
            heading size: 3, text: 'Three other persons:'
          end
          @other_persons.each do |person|
            div class: 'col-md-4' do
              person_card person: person, path: :admin_person_path
            end
          end
        end
      end
    end
  end

  def delete_person_config
    return {
      method: :delete,
      path: :admin_person_path,
      params: {
        id: @person.id
      },
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


# app/matestack/admin/pages/persons/new.rb
class Admin::Pages::Persons::New < Matestack::Ui::Page

  def prepare
    @person = Person.new
  end

  def response
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-6 offset-md-3 text-center' do
            heading size: 2, text: 'Create new person'
            form new_person_form_config, :include do
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'First name:'
                div class: 'col-sm-8' do
                  form_input key: :first_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Last name:'
                div class: 'col-sm-8' do
                  form_input key: :last_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Person role:'
                div class: 'col-sm-8' do
                  form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: Person.roles.keys.first
                end
              end
              form_submit do
                transition path: :persons_path, class: 'btn btn-secondary my-3', text: 'Back to index page'
                button class: 'btn btn-primary', text: 'Create person'
              end
            end
          end
        end
      end
    end
  end

  def new_person_form_config
    {
      for: @person,
      method: :post,
      path: :admin_persons_path,
      success: {
        transition: {
          follow_response: true
        }
      }
    }
  end

end


# app/matestack/admin/pages/persons/edit.rb
class Admin::Pages::Persons::Edit < Matestack::Ui::Page

  def response
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-6 offset-md-3 text-center' do
            heading size: 2, text: "Edit Person: #{@person.first_name} #{@person.last_name}"
            form person_edit_form_config, :include do
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'First name:'
                div class: 'col-sm-8' do
                  form_input key: :first_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Last name:'
                div class: 'col-sm-8' do
                  form_input key: :last_name, class: 'form-control', type: :text
                end
              end
              div class: 'form-group row' do
                label class: 'col-sm-4 col-form-label col-form-label-md', text: 'Person role:'
                div class: 'col-sm-8' do
                  form_select key: :role, type: :dropdown, class: 'form-control', options: Person.roles.keys, init: @person.role
                end
              end
              form_submit do
                transition path: :admin_person_path, params: { id: @person.id }, class: 'btn btn-secondary my-3', text: 'Back to detail page'
                button class: 'btn btn-primary', text: 'Save changes'
              end
            end
          end
        end
      end
    end
  end

  def person_edit_form_config
    {
      for: @person,
      method: :patch,
      path: :admin_person_path,
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

The newly added pages let us perform CRUD operations on the `Person` records in the database, but we still need a login page. Go ahead and add it in `app/matestack/admin/pages/sessions/sign_in.rb` with this content:

```ruby
class Admin::Pages::Sessions::SignIn < Matestack::Ui::Page

  def response
    section do
      div class: 'container' do
        div class: 'row' do
          div class: 'col-md-4 offset-md-4' do
            div class: 'card' do
              div class: 'card-body text-center' do
                heading text: t('devise.sessions.new.login')
                partial :login_form
              end
            end
          end
        end
      end
    end
  end

  private

  def login_form
    form form_config, :include do
      div class: 'form-group row' do
        label class: 'col-sm-12 col-form-label col-form-label-md', text: t('devise.sessions.new.email')
        div class: 'col-sm-12' do
          form_input key: :email, type: :text
        end
      end
      div class: 'form-group row' do
        label class: 'col-sm-12 col-form-label col-form-label-md', text: t('devise.sessions.new.password')
        div class: 'col-sm-12' do
          form_input key: :password, type: :password
        end
      end
      form_submit class: 'text-center d-block' do
        button class: 'btn btn-primary text-center', text: I18n.t('devise.sessions.new.login')
      end
    end
  end

  def form_config
    {
      for: :admin,
      method: :post,
      path: :admin_session_path,
      success: { 
        emit: "reload_page", 
        transition: { follow_response: true } 
      },
      failure: { emit: "login_failed" }
    }
  end

end
```

Notice how we're making use of the `emit: "reload_page"`-event again. This page is also the first time we are facing `locales` in this guide! Those are a neat way to separate content from your page structure & logic and come in handy once you want to use different languages for the same project!

Let's first add a default locale in `config/application.rb`, setting it like so:

```ruby
# ...
class Application < Rails::Application
    # ...
    config.i18n.default_locale = :en
    # ...
end
# ...
```

To extend the auto-generated `Devise` locales with the texts we need, update `config/locales/devise.en.yml` with the following lines:

```yaml
en:
  devise:
    confirmations:
      # ...
    # ...
    sessions:
      new:
        login: "Login"
        email: "E-Mail"
        password: "Password"
        login_failed: "Login failed."
      logout: "Logout"
    # ...
```

Let's save the current status quo to Git by running

```sh
git add app/matestack/admin/app.rb app/matestack/admin/pages/sessions/sign_in.rb app/matestack/admin/pages/persons/ config/application.rb config/locales/devise.en.yml
```

and

```sh
git commit -m "Add AdminApp & Pages, set default language & extend devise locales"
```

### Admin Controllers
Now that we have a new `matestack` app and some pages, we will need corresponding controller actions!

Create a folder as `app/controllers/admin/` and add the following three files:

```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  helper_method :current_admin
end


# app/controllers/admin/persons_controller.rb
class Admin::PersonsController < Admin::BaseController
  layout 'administration'
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  matestack_app Admin::App

  def new
    render Admin::Pages::Persons::New
  end

  def index
    render Admin::Pages::Persons::Index
  end

  def show
    render Admin::Pages::Persons::Show
  end

  def edit
    render Admin::Pages::Persons::Edit
  end

  def update
    @person.update person_params

    @person.save
    if @person.errors.any?
      render json: {errors: @person.errors}, status: :unprocessable_entity
    else
      render json: { transition_to: admin_person_path(id: @person.id) }, status: :ok
    end
  end

  def create
    @person = Person.new(person_params)
    @person.save

    if @person.errors.any?
      render json: {errors: @person.errors}, status: :unprocessable_entity
    else
      render json: { transition_to: admin_person_path(id: @person.id) }, status: :created
    end
  end

  def destroy
    if @person.destroy
      render json: { transition_to: admin_persons_path }, status: :ok
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
      :active,
      :role
    )
  end

end


# app/controllers/admin/sessions_controller.rb
class Admin::SessionsController < Devise::SessionsController
  layout 'administration'
  before_action :configure_sign_in_params, only: [:create]

  def new
    render Admin::Pages::Sessions::SignIn, matestack_app: Admin::App
  end

  def create
    errors = {}
    [:email, :password].each do |key|
      errors[key] = ["Can't be blank"] if params[:admin][key].blank?
    end
    if errors.empty?
      admin = warden.authenticate(auth_options)
      sign_in(:admin, admin)
      redirect_to admin_persons_path
    else
      render json: {errors: errors}, status: :unprocessable_entity
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    redirect_to new_admin_session_path, status: :see_other
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end

end
```

What's going on here? Let's break it down one after another:

- The `BaseController` wraps the other admin controllers and protects them from unjustified requests by running `:authenticate_admin!` in a `before_action`. It also makes the `Devise` helper `:current_admin` available in both controller actions and associated `matestack` apps&pages.
- The `PersonsController`, like in our `DemoApp`, lets us perform CRUD operations on the `Person` model.
- The `SessionsController` manages the admin sessions by providing the login page (`new` action), sign in functionality (`create` action) and logout (`destroy` action).

### Admin Routes
What's left for us to do is update the routes accordingly, so head over to `config/routes.rb` and add the following lines:

```ruby
devise_for :admins, controllers: {
  sessions: 'admin/sessions'
}

namespace :admin do
  root to: 'persons#index'
  resources :persons
end
```

The first part tells Rails to use the `Admin::SessionsController` for session management, while the second part creates an `admin` namespace for our `AdminApp`. Now we can either access the `Person` pages as a normal visitor under `localhost:3000/persons` or as an admin under `localhost:3000/admin/persons`!

To make it usable for both routes, we need to update our custom static `card component` in `app/matestack/components/person/card.rb`:

```ruby
class Components::Person::Card < Matestack::Ui::StaticComponent

  def prepare
    @person = @options[:person]
    @path = @options[:path]
  end

  def response
    div class: 'card' do
      div class: 'card-body' do
        paragraph text: "#{@person.first_name} #{@person.last_name}"
        transition path: @path, params: {id: @person.id}, class: 'btn btn-primary', text: 'Details'
      end
    end
  end

end
```

and then change `person_card person: person` to `person_card person: person, path: :person_path` in both `app/matestack/demo/pages/persons/index.rb` and `app/matestack/demo/pages/persons/show.rb`.

Again, as a milestone commit the recent changes by running

```sh
git add app/controllers/admin/ config/routes.rb app/matestack/components/person/card.rb app/matestack/demo/pages/persons/
```

and

```sh
git commit -m "Add admin controllers & routes, update card component to accept routes"
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
    <div id="matestack_ui">
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
import 'css/loading-spinner'

import 'jquery'
import 'popper.js'
import 'bootstrap'

import MatestackUiCore from 'matestack-ui-core'
import '../../matestack/components/person/disclaimer'
import '../../matestack/components/person/activity'
import 'animations/loading-spinner'
import 'events/reload-page'
```

When you compare it to `app/javascript/packs/application.js` which sits right next to it, you will see that the two diverge in two points: The admin pack imports two different files in `'css/custom-admin-bootstrap'` and `'events/reload-page'`, so we need to a add them!

Here's the `custom-admin-bootstrap.scss` which you need to add in `app/javascript/css/`, using a different color scheme than our `DemoApp`:

```css
$body-bg: ghostwhite;
$body-color: #101;

$theme-colors: (
  "primary": purple,
  "info": darkcyan,
  "warning": darkred
);

@import "~bootstrap/scss/bootstrap.scss";

@import '../../matestack/components/person/disclaimer';
```

As you can see, it also sets CSS variables and imports Bootstrap and our custom component stylings.

Lastly, add a new file in `app/javascript/events/reload-page.js`, containgin the following lines:

```js
MatestackUiCore.matestackEventHub.$on('reload_page', function(){
  setTimeout(function () {
    location.reload()
  }, 500);
})
```

This is where the `emit: "reload_page"` we introduced in two `matestack` actions during this article gets handled - as you can see, we make use of the `matestackEventHub` and, upon receiving the event, reload the page after 500ms. This is being done so the Navbar in our `AdminApp` re-/disappears and we make sure the current admin session is correctly created/destroyed.

Again, as a milestone commit the recent changes by running

```sh
git add app/views/layouts/administration.html.erb app/javascript/
```

and

```sh
git commit -m "Add admin layout, admin css & admin JS pack"
```

## Reducing functionality in the DemoApp and adding an admin login button
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
    # ...
      li class: 'nav-item' do
        link class: 'nav-link', path: :new_admin_session_path, text: 'Admin Login'
      end
    # ...
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

Here's a quick overview: Instead over implementing loads of (complex) functionality with a load of implications and edge cases, we use the `Devise` gem for a rock-solid authentication. It takes care of hasing, salting and storing the password, and through the `Devise::SessionsController`, of managing the session cookie. All that's left for us to do is check for the existence of said cookie by using the `authenticate_admin!` helper. If the required cookie is not present, the controller responds with an error code.

`Devise` could do a lot more, but as this is a basic guide, we will leave it with that. For even more fine-grained control over access rights (authorization) within your application (e.g. by introducing a superadmin or having regional and national manager roles), we recommend to take a look at two other popular Ruby/Rails gems, [Pundit](https://github.com/varvet/pundit) and [CanCanCan](https://github.com/CanCanCommunity/cancancan).

## Deployment
Time to move all the new functionality to the live application. Make sure the relevant changes are commited to Git and run

```sh
git push heroku master
```

to trigger a deployment. After that has succeeded, since we modified the `schema.rb` and added an admin table to our database, we need to run

```sh
heroku run rake db:migrate
```

once more.

Now, in order to being able to log in, we still need to create an admin record. We could add one to our seeds, but let's check out another feature of `Heroku` and open the Rails console of our live application by running

```sh
heroku run rails console
```

Neat! There, we create an admin via the following code snippet:

```ruby
a = Admin.create(email: 'admin@example.com', password: 'OnlyForSuperMates', password_confirmation: 'OnlyForSuperMates')
```

After seeing a success message, run

```sh
heroku open
```

to check out the latest additions to the application!

## Recap & outlook
By adding a working authentication functionality and an admin behind a login, our project now resembles a real-world software applications! On the way there, we covered some advanced topics like authentication via the `Devise` gem, serving different JavaScript packs using `Webpacker` and Rails `layouts` as well as adding text via `locales`.

While the application is good as it is right now, go ahead and check out the [final part of this guide](/guides/essential/10_wrap_up.md).
