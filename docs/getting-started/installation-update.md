# Installation & Update

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core'
```

and run

```
$ bundle install
```

### Matestack folder

Create a folder called 'matestack' in your app directory. All your Matestack apps, pages and components will be defined there.

```
$ mkdir app/matestack
```

### Controller setup

Add the Matestack helper to your controllers. If you want to make the helpers available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::Helper
  #...
end
```

Now, you are able to create UI components in pure Ruby and use them in your Rails views. Additionally you can substitute Rails views and layouts with Matestack pages and apps.

If you want to use Matestack's optional reactivity features in pure Ruby (through dynamic Vue.js components such as `form` and `async` or dynamic page transitions), please perform the next steps to set up the JavaScript parts via Webpacker.

{% hint style="info" %}
Matestack's JavaScript is only required if you want to use reactive features. It's totally valid to just use the "static" features of Matestack, namely implement UI components, pages and apps in pure Ruby.
{% endhint %}

### Webpacker

Add 'matestack-ui-core' to your `package.json` by running:

```
$ yarn add matestack-ui-core
```

This adds the npm package that provides the JavaScript corresponding to the matestack-ui-core ruby gem. Make sure that the npm package version matches the gem version. To find out what gem version you are using, you may use `bundle info matestack-ui-core`.

Next, import and setup 'matestack-ui-core' in your `app/javascript/packs/application.js`

```javascript
import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'

import MatestackUiCore from 'matestack-ui-core'

let matestackUiApp = undefined

document.addEventListener('DOMContentLoaded', () => {
  matestackUiApp = new Vue({
    el: "#matestack-ui",
    store: MatestackUiCore.store
  })
})
```

and compile the JavaScript code with webpack:

```
$ bin/webpack --watch
```

{% hint style="warning" %}
When you update the `matestack-ui-core` Ruby gem, make sure to update the npm package as well!
{% endhint %}

### Usage with Turbolinks/Turbo

If you want to use `matestack-ui-core` alongside with Turbolinks or Turbo, please add:

```bash
yarn add vue-turbolinks
```

And use following snippet instead:

```javascript
import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'

import MatestackUiCore from 'matestack-ui-core'

import TurbolinksAdapter from 'vue-turbolinks'; // import vue-turbolinks
Vue.use(TurbolinksAdapter); // tell Vue to use it

let matestackUiApp = undefined

// change the trigger event
document.addEventListener('turbolinks:load', () => {
  matestackUiApp = new Vue({
    el: "#matestack-ui",
    store: MatestackUiCore.store
  })
})
```

### Application layout adjustments

You need to add the ID "matestack-ui" to some part of your application layout (or any layout you use). That's required for Matestack's Vue.js to work properly!

For Example, your `app/views/layouts/application.html.erb` should look like this:

```markup
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

{% hint style="warning" %}
Don't apply the "matestack-ui" id to the body tag.
{% endhint %}

### ActionCable Integration

Some of Matestack's reactive core components may be used with or require ActionCable. If you want to use ActionCable, please read the action cable guide:

{% content-ref url="../integrations/action-cable.md" %}
[action-cable.md](../integrations/action-cable.md)
{% endcontent-ref %}

## Update

### Ruby Gem

Depending on the entry in your Gemfile, you might need to adjust the allowed version ranges in order to update the Gem. After checked and adjusted the version ranges, run:

```bash
bundle update matestack-ui-core
```

and then check the installed version:

```bash
bundle info matestack-ui-core
```

### JavaScript Package

If you've installed the JavaScript dependecies via Yarn/Webpacker you need to update the JavaScript assets via yarn:

```bash
yarn upgrade matestack-ui-core
```

{% hint style="warning" %}
Ensure to update the JavaScript dependency version in your package.json if the version specified on it is locked.
{% endhint %}

and finally check if the correct version is installed:

```bash
yarn list --pattern "matestack-ui-core"
```

{% hint style="warning" %}
The Ruby gem version and the npm package version should match!
{% endhint %}
