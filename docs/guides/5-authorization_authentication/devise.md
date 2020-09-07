# Integrating Devise

Devise is one of the most popular gems for authentication. Find out more about Devise [here](https://github.com/plataformatec/devise/).

In order to integrate it fully in matestack apps and pages we need to adjust a few things. This guide explains what exactly needs to be adjusted.

## Setting up Devise

We install devise by following devise [installation guide](https://github.com/plataformatec/devise/#getting-started).

First we add `gem 'devise'` to our `Gemfile` and run `bundle install`. Afterwards we need to run devise installation task with `rails generate devise:install`.

Then we need to add an action mailer config like devise tolds us at the end of the installation task. We therefore add the following line to our `config/environments/development.rb`.

```ruby
config.action_mailer.default_url_options = {
  host: 'localhost',
  port: 3000
}
```

## Devise Model

Generating a devise model or updating an existing one works as usual. Just use devise generator to create a model. If you already have a model which you want to extend for use with devise take a look at the devise documentation on how to do so.

Let's create a user model for example by running
```sh
rails generate devise user
```

And ensure `devise_for :user` is added to the `app/config/routes.rb`

## Devise Helpers

Again nothing unusual here. We can access devise helper methods inside our controllers, apps, pages and components like we would normally do. In case of our user model this means we could access `current_user` or `user_signed_in?` in apps, pages and components.

For example:
```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    plain "Logged in as #{current_user.email}" if user_signed_in?
    plain "Hello World!"
  end

end
```

In our controller we also use devise like it is described by devise documentation. For example checking a user is authenticated before he can access a specific controller by calling `authenticate_user!` in a before action.

```ruby
class ExampleController < ApplicationController
  before_action :authenticate_user!

  def index
    render ExamplePage
  end

end
```

## Devise Login

Using the default devise login views should work without a problem, but they will not be integrated inside a matestack app. Let's assume we have a profile matestack app called `Profile::App`. If we want to take advantage of matestacks transitions features (not reloading our app layout between page transitions) we can not use devise views, because we would need to redirect to them and therefore need to reload the whole page. Requiring us for example to implement our navigation twice. In our `Profile::App` and also in the our devise sign in view.

Therefore we need to adjust a few things and create some pages. First we need a custom sign in page containing a form with email and password inputs.

`app/matestack/profile/pages/sessions/sign_in.rb`
```ruby 
class Profile::Pages::Sessions::SignIn < Matestack::Ui::Page

  def response
    heading text: 'Login'
    form form_config do
      form_input label: 'Email', key: :email, type: :email 
      form_input label: 'Password', key: :password, type: :password 
      form_submit do
        button text: 'Login'
      end
    end
    toggl show_on: 'login_failure' do
      'Your email or password is not valid.'
    end
  end

  private

  def form_config
    for: :user,
    method: :post,
    path: user_session_path,
    success: {
      transition: {
        follow_response: true
      }
    },
    failure: {
      emit: 'login_failure'
    }
  end

end
```

This page displays a form with a email and password input. The default required parameters for a devise login. It also contains a `toggle` component which gets shown when the event `login_failure` is emitted. This event gets emitted in case our form submit was unsuccessful as we specified it in our `form_config` hash. If the form is successful our app will make a transition to the page the server would redirect to.

In order to render our sign in page when someone tries to access a route which needs authentication or someone visits the sign in page we must override devise session controller in order to render this page. We do this by configuring our routes to use a custom controller.

`app/config/routes.rb`
```ruby
Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

end
```

Override the `new` action in order to render our sign in page.

`app/controllers/users/sessions_controller.rb`
```ruby
class Users::SessionController < Devise::SessionController
  # include your component registry in order to use custom components
  include Components::Registry

  matestack_app Profile::App # specify the corresponding app to wrap pages in

  # override in order to render a page
  def new
    render Profile::Pages::Sessions::SignIn
  end

end
```

Finally we need to override the create method in order to fully leverage matestacks potential. Matestack expects to retrieve a json response with a html error code if the sign in has failed due to matestacks form error handling. To achieve this we need to override the `create` method as you can see below:

```ruby
def create
  self.resource = warden.authenticate(auth_options)
  return render json: {}, status: 401 unless resource
  sign_in(resource_name, resource)
  respond_with resource, location: after_sign_in_path_for(resource)
end
```

We stayed as close to devise implementation as possible. The important part is line 3 where we return a json response with error code 401 if warden couldn't authenticate the resource.

**Wrap Up**
That's it. Now you have a working fully integrated login with devise and matestack. All we needed to do was to create a sign in page, update our routes to use a custom session controller and override two methods in this controller. 

## Devise logout

----
TODO devise logout, registration etc.
----




## Example

This is just your average Rails user controller. The `before_action` gets called on initial pageload and on every subsequent AJAX request the client sends.

```ruby
class UserController < ApplicationController
  before_action :authenticate_user! # Devise authentication
  matestack_app UserApp

  def show
    render UserApp::Pages::Show # matestack page responder
  end

end
```
