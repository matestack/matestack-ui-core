# Authentication via Devise

We recommend using a proven authentication solution like Devise for your Rails app. Find out more about Devise [here](https://github.com/plataformatec/devise/).

## Setting up Devise with your existing matestack application

Just follow the [Devise installation guide](https://github.com/plataformatec/devise/#getting-started) and add it to the models and controller actions you want.

## Adding matestack to a Rails app that already uses Devise

As Devise mainly lives in your models and controllers while matestack is meant to replace your view layer, there shouldn't be much to change for you. Just make sure to trigger the right `before_action`s when adding matestack's `render` to a controller action!


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
