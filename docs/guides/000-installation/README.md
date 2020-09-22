# Installation Guide

This guide shows you how to add matestack-ui-core to an existing rails application.

1. [Installation](#installation)
   1. [JavaScript Setup](#javascript-setup)
   2. [Matestack Folder](#matestack-folder)
   3. [Controller Setup](#controller-setup)
   4. [Application layout adjustments](#application-layout-adjustments)
   5. [Websocket Integration](#websocket-integration)
2. [Usage](#usage)
   1. [Full matestack](#full-matestack)
   2. [Integration in existing projects](#integration-in-existing-projects)

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core', '~> 1.0.0'
```

and run

```shell
$ bundle install
```

### JavaScript Setup

Matestack uses JavaScript and, in particular, [vuejs](http://vuejs.org). To include these into your existing rails app, matestack supports both, [webpack](https://webpack.js.org/)([er](https://github.com/rails/webpacker/)) and the [asset pipeline](https://guides.rubyonrails.org/asset_pipeline.html).

Rails 6+ apps use webpacker by default. Rails 5 and below apps use the asset pipeline by default.

#### Webpacker

Add 'matestack-ui-core' to your `package.json` by running:

```
$ yarn add https://github.com/matestack/matestack-ui-core#v1.0.0
$ yarn install
```

This adds the npm package that provides the javascript corresponding to the matestack-ui-core ruby gem. Make sure that the npm package version matches the gem version. To find out what gem version you are using, you may use `bundle info matestack-ui-core`.

Next, import 'matestack-ui-core' in your `app/javascript/packs/application.js`

```js
import MatestackUiCore from 'matestack-ui-core'
```

and compile the JavaScript code with webpack:

```
$ bin/webpack
```

When you update the matestack-ui-core gem, make sure to update the npm package as well.

#### Asset Pipeline

If you are using the asset pipeline, you don't need to install the separate npm package. All required javascript libraries are provided by the matestack-ui-core gem.

Require 'matestack-ui-core' in your `app/assets/javascript/application.js`

```javascript
//= require matestack-ui-core
```

#### Turbolinks

We recommend to (remove/deactivate)(https://stackoverflow.com/a/38649595) turbolinks, as there is no reason to use it alongside matestack-ui-core and there might appear some strange side effects. If you encounter strange page-transition/form-submit/action-submit behavior and have turbolinks activated, try to deactivate it first.

### Matestack Folder

Create a folder called 'matestack' in your app directory. All your matestack apps,
pages and components will be defined there.

### Controller Setup

Add the matestack helper to your controllers. If you want to make the helpers
available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  #...
end
```

### Application layout adjustments

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
Don't apply the "matestack-ui" id to the body tag.


### Websocket Integration

If you want to use websockets, please read our [action cable](/docs/guides/1000-action_cable/) guide.


### That's it!

That's all you need to setup matestack!

For further reading check out the [basic building blocks](/docs/guides/200-basic_building_blocks/) or get started with the [tutorial](/docs/guides/100-tutorial/) and create your first matestack app.


## Usage

There are two ways to use matestack. 

### Full matestack

First, as we call it, _full matestack_, enabling all features and developing with all benefits. Learn more about the _full matestack_  approach by following the [tutorial](/docs/guides/100-tutorial/README.md) or reading about matestacks [basic building blocks](/docs/guides/200-basic_building_blocks/README.md). 

### Integration in existing projects

Secondly integrating matestack in your existing rails application. Building custom components and replacing/migrating/refactoring your views step by step to use matestack. Rendering your custom components can be achieved with the `matestack_component` helper available in views. For example `<%= matestack_component(:user_stats, user: user) %>`. It is also possible to use existing `haml` views with components or render rails views inside a page. Read more about how to integrate matestack into existing projects in our [Rails integration guide](/docs/guides/300-rails-integration/README.md).
