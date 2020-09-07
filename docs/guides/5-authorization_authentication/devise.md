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

## Devise Login and Logout

Using the default devise login views should work without a problem, but they will not be integrated inside a matestack app. Let's assume we have a profile matestack app called `Profile::App`. If we want to take advantage of matestacks transitions features (not reloading our app layout between page transitions) we can not use devise views, because we would need to redirect to them and therefore need to reload the whole page. Requiring us for example to implement our navigation twice. In our `Profile::App` and also in the our devise sign in view.

Therefore we need to adjust a few things and create some pages. First we need a custom sign in page containing a form with email and password inputs.

`app/matestack/profile/pages/sign_in.rb`
```ruby 
class Profile::Pages::SignIn < Matestack::Ui::Page

  def response
    heading text: 'Login'
    form form_config do
      form_input label: 'Email', key: :email, type: :email 
      form_input label: 'Password', key: :password, type: :password 
      form_submit do
        button text: 'Login'
      end
    end
  end

  private

  def form_config
    for: :user,
    method: :post,
    path: user_session_path
  end

end
```

```

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
