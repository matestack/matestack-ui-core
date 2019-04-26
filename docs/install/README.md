# Install

If your're using the classic Rails assets pipeline, this guide shows you how to
add matestack to your Rails app.

## Gemfile

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core'
```

and run

```shell
$ bundle install
```

## Javascript

Require 'matestack-ui-core' in your `assets/javascript/application.js`

```javascript
//= require matestack-ui-core
```

## Matestack Folder

Create a folder called 'matestack' in your app directory. All your matestack apps,
pages, components (and more to come) will be defined there.

## Include Helper

Add the matestack helper to your controllers. If you want to make the helpers
available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  #...
end
```

## Application Layout

You need to add the ID "matestack_ui" to some part of your application layout (or any layout you use)

For Example, your `app/views/layouts/application.html.erb` should look like this:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    'application', media: 'all' %>
    <%= javascript_include_tag 'application' %>
  </head>

  <body>
    <div id="matestack_ui">
      <%= yield %>
    </div>
  </body>
</html>


```
Don't apply the matestack_ui ID to the body tag.

## Extend Asset Paths

In order to enable custom Vue.js components, add the matestack folder to the asset paths:

`config/initializers/assets.rb`

```ruby
Rails.application.config.assets.paths << Rails.root.join('app/matestack/components')
```
