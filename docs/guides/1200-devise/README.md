# Integrating Devise

Devise is one of the most popular gems for authentication. Find out more about Devise [here](https://github.com/plataformatec/devise/).

In order to integrate it fully in matestack apps and pages we need to adjust a few things. This guide explains what exactly needs to be adjusted.

## Table of contents

- [Integrating Devise](#integrating-devise)
  - [Table of contents](#table-of-contents)
  - [Setting up Devise](#setting-up-devise)
  - [Devise models](#devise-models)
  - [Devise helpers](#devise-helpers)
  - [Devise sign in](#devise-sign-in)
  - [Devise sign out](#devise-sign-out)

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

## Devise models

Generating a devise model or updating an existing one works as usual. Just use devise generator to create a model. If you already have a model which you want to extend for use with devise take a look at the devise documentation on how to do so.

Let's create a user model for example by running
```sh
rails generate devise user
```

And ensure `devise_for :user` is added to the `app/config/routes.rb`

## Devise helpers

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

## Devise sign in

Using the default devise sign in views should work without a problem, but they will not be integrated with a matestack app. Let's assume we have a profile matestack app called `Profile::App`. If we want to take advantage of matestacks transitions features (not reloading our app layout between page transitions) we can not use devise views, because we would need to redirect to them and therefore need to reload the whole page. Requiring us for example to implement our navigation twice. In our `Profile::App` and also in our devise sign in view.

Therefore we need to adjust a few things and create some pages. First we create a custom sign in page containing a form with email and password inputs.

`app/matestack/profile/pages/sessions/sign_in.rb`

```ruby 
class Profile::Pages::Sessions::SignIn < Matestack::Ui::Page

  def response
    heading text: 'Sign in'
    form form_config do
      form_input label: 'Email', key: :email, type: :email 
      form_input label: 'Password', key: :password, type: :password 
      form_submit do
        button text: 'Sign in'
      end
    end
    toggl show_on: 'sign_in_failure' do
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
      emit: 'sign_in_failure'
    }
  end

end
```

This page displays a form with an email and password input. The default required parameters for a devise sign in. It also contains a `toggle` component which gets shown when the event `sign_in_failure` is emitted. This event gets emitted in case our form submit was unsuccessful as we specified it in our `form_config` hash. If the form is successful our app will make a transition to the page the server would redirect to. 

Remember to use `redirect` instead of `transition`, if you have conditional content depending on a logged in user inside your app. You have to use `redirect` because the app needs to be reloaded, which happens only with `redirect`.

In order to render our sign in page when someone tries to access a route which needs authentication or visits the sign in page we must override devise session controller in order to render our page. We do this by configuring our routes to use a custom controller.

`app/config/routes.rb`

```ruby
Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

end
```

Override the `new` action in order to render our sign in page and set the correct matestack app in the controller. Also remember to include the components registry. This is necessary if you use custom components in your app or page, because without it matestack can't resolve them.

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

Now our sign in is nearly complete. Logging in with correct credentials works fine, but logging in with incorrect credentials triggers a page reload and doesn't show our error message. 

Devise usually responds with a 401 for wrong credentials but intercepts this response and redirects to the new action. This means our `form` component recieves the response of the `new` action, which would have a success status. Therefore it redirects you resulting in a rerendering of the sign in page. So our `form` component needs to recieve a error code in order to work as expected. To achieve this we need to provide a custom failure app.

Create the custom failure app under `lib/devise/json_failure_app.rb` containing following code:

```ruby
class JsonFailureApp < Devise::FailureApp

  def respond
    return super unless request.content_type == 'application/json'
    self.status = 401
    self.content_type = :json
  end

end
```

We only want to overwrite the behavior of the failure app for request with `application/json` as content type, setting the status to a 401 unauthorized error and the content_type to json.

There is only one thing left, telling devise to use our custom failure app. Therefore add/update the following lines in `config/initializers/devise.rb`.

```ruby
require "#{Rails.root}/lib/devise/json_failure_app"

config.warden do |manager|
  manager.failure_app = JsonFailureApp
end
```

That's it. When we now try to sign in with incorrect credentials the `form` component triggers the `sign_in_failure` event, which sets off our `toggle` component resulting in displaying the error message.

**Wrap Up**
That's it. Now you have a working sign in with devise fully integrated into matestack. All we needed to do was creating a sign in page, updating our routes to use a custom session controller, overriding the new action, creating a custom failure app and updating the devise config.


## Devise sign out

Creating a sign out button in matestack is very straight forward. We use matestacks [`action` component](/docs/api/100-components/action.md) to create a sign out button. See the example below:

```ruby
action sign_out_config do
  button text: 'Sign out'
end
```

```ruby
def sign_out_config 
  {
     method: :get,
     path: destroy_admin_session_path,
     success: {
       transition: {
         follow_response: true
       }
     }
  }
end
```

Notice the `method: :get` in the configuration hash. We use a http GET request to sign out, because the browser will follow the redirect send from devise session controller and then matestack tries to load the page where we have been redirected to. When we would use a DELETE request the action we would be redirected to from the browser will be also requested with a http DELETE request, which will result in a rails routing error. Therefore we use GET and need to configure devise accordingly by changing the `sign_out_via` configuration parameter.

```ruby
# The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :get
```

That's all we have to do.
