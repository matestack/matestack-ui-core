# Install

This guide shows you how to add matestack-ui-core to an existing rails application.

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

Matestack uses javascripts and, in particular, [vuejs](http://vuejs.org). To include these into your existing rails app, matestack supports both, [webpack](https://webpack.js.org/)([er](https://github.com/rails/webpacker/)) and the [asset pipeline](https://guides.rubyonrails.org/asset_pipeline.html).

Rails 6+ apps, by default, use webpacker, rails 5 apps, by default, use the asset pipeline.

### Webpacker

Add 'matestack-ui-core' to your `package.json` by running:

```
$ yarn add https://github.com/matestack/matestack-ui-core#v1.0.0
$ yarn install
```

This adds the npm package that provides the javascript files corresponding to matestack-ui-core ruby gem. Make sure that the npm package version matches the gem version. To find out what gem version you are using, you may use `bundle info matestack-ui-core`.

Next, import 'matestack-ui-core' in your `app/javascript/packs/application.js`

```js
import MatestackUiCore from 'matestack-ui-core'
```

and compile the javascript code with webpack:

```
$ bin/webpack
```

When, in the future, you update the matestack-ui-core gem, make also sure to update the npm package as well.

### Asset Pipeline

If you are not using webpacker but the asset pipeline, you don't need to install a separate npm package. All required javascript libraries including vuejs are provided by matestack-ui-core ready-to-use via the asset pipeline.

Require 'matestack-ui-core' in your `app/assets/javascript/application.js`

```javascript
//= require matestack-ui-core
```

Require 'matestack-ui-core' in your `app/assets/stylesheets/application.css`

```css
/*
 *= require matestack-ui-core
 */
```

### Turbolinks

Since `0.7.5`, matestack-ui-core is compatible with activated [turbolinks](https://github.com/turbolinks/turbolinks).

We recommend to (remove/deactivate)(https://stackoverflow.com/a/38649595) turbolinks, as there is no real reason to use it alongside matetack-ui-core UI dynamics and there might appear some strange side effects. If you encounter strange page-transition/form-submit/action-submit behavior and have turbolinks activated, try to deactivate it first.

## Matestack Folder

Create a folder called 'matestack' in your app directory. All your matestack apps,
pages and components will be defined there.

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

You need to add the ID "matestack-ui" to some part of your application layout (or any layout you use)

For Example, your `app/views/layouts/application.html.erb` should look like this:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    'application', media: 'all' %>

    <!-- if you are using webpacker: -->
    <%= javascript_pack_tag 'application' %>

    <!-- if you are using the asset pipeline: -->
    <%= javascript_include_tag 'application' %>
  </head>

  <body>
    <div id="matestack-ui">
      <%= yield %>
    </div>
  </body>
</html>
```
Don't apply the matestack_ui ID to the body tag.

## Adding Support for Custom Components

If you intend to write custom dynamic matestack components for your app, you need to make those accessible to the matestack-ui-core javscript code.

### Webpack

When using webpack, make sure to import your custom components in `app/javascript/packs/application.js`:

```js
import MatestackUiCore from 'matestack-ui-core'
import '../../../app/matestack/components/my_custom_component'
```

### Asset Pipeline

When using the asset pipeline, add the matestack folder to the asset paths:

```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join('app/matestack/components')
```

## Websocket Integration

If you want to use websockets, please read [this guide](/docs/integrations/websockets.md)

## That's it!

That's all you need to setup matestack!

For your next steps in learning matestack we recommend you check out the basics [concepts](/docs/concepts/README.md) and follow the [hello world guide](/guides/10_hello_world.md) which shows you how to create your first matestack app!
