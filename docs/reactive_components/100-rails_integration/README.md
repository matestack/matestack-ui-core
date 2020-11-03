# Rails integration

Matestack's JavaScript needs to be integrated into your Rails application in order to use the reactive, JavaScript driven features. You can use Webpacker (recommended) or Rails assets pipeline to do this.

## Webpacker

Add 'matestack-ui-core' to your `package.json` by running:

```
$ yarn add https://github.com/matestack/matestack-ui-core#v1.1.0
$ yarn install
```

This adds the npm package that provides the JavaScript corresponding to the matestack-ui-core ruby gem. Make sure that the npm package version matches the gem version. To find out what gem version you are using, you may use `bundle info matestack-ui-core`.

Next, import 'matestack-ui-core' in your `app/javascript/packs/application.js`

```js
import MatestackUiCore from 'matestack-ui-core'
```

and compile the JavaScript code with webpack:

```
$ bin/webpack --watch
```

**When you update the matestack-ui-core gem, make sure to update the npm package as well.**

## Asset Pipeline

If you are using the asset pipeline, you don't need to install the separate npm package. All required JavaScript libraries are provided by the matestack-ui-core gem.

Require 'matestack-ui-core' in your `app/assets/javascript/application.js`

```javascript
//= require matestack-ui-core
```

## Turbolinks

We recommend to (remove/deactivate)(https://stackoverflow.com/a/38649595) turbolinks, as there is no reason to use it alongside matestack-ui-core and there might appear some strange side effects. If you encounter strange page-transition/form-submit/action-submit behavior and have turbolinks activated, try to deactivate it first.

## Application layout adjustments

You need to add the ID "matestack-ui" to some part of your application layout (or any layout you use). That's required for Matestack's Vue.js to work properly!

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


### ActionCable Integration

Some of Matestack's reactive core components may be used with ActionCable. If you want to use ActionCable, please read our [action cable](/docs/reactive_components/1000-action_cable/) guide.
