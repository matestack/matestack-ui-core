# Migrating from 2.x to 3.0

# Installation & setup changes

## Core/Vuejs repo and gem split

- `matestack-ui-core` previously contained logic for
  - Ruby -> HTML conversion
  - Reactivity via prebuilt and custom Vue.js components
- in order to have better seperation of concerns, we've moved the reactivity related things to its own repository/gem -> `matestack-ui-vue_js`
- `matestack-ui-core` is now meant to be combined with any reactivity framework or none at all

If you've used reactivity features of `matestack-ui-core` 2.x you now have to install `matestack-ui-vue_js` (Ruby Gem & NPM Package) additionally:

`Gemfile`
```ruby
gem 'matestack-ui-core', '~> 3.0'
gem 'matestack-ui-vue_js', '~> 3.0'
```

**only for `matestack-ui-vue_js` users!**

`package.json`
```json
{
  "name": "my-app",
  "dependencies": {
    "matestack-ui-vue_js": "^3.0.0", // <-- new package name
    "..."
  }
}

```

## IE 11 support dropped

**only for `matestack-ui-vue_js` users!**

- vue3 dropped IE 11 support
- when using babel alongside webpacker, please adjust your package.json or .browserslistrc config in order to exclude IE 11 support:

```json
{
  "name": "my-app",
  "...": { },
  "browserslist": [
    "defaults",
    "not IE 11" // <-- important!
  ]
}
```

Otherwise you may encounter issues around `regeneratorRuntime` (especially when using Vuex)

## Setup via webpacker

**only for `matestack-ui-vue_js` users!**

`config/webpack/environment.js`
```js
const { environment } = require('@rails/webpacker')
const webpack = require('webpack');

const customWebpackConfig = {
  resolve: {
    alias: {
      vue: 'vue/dist/vue.esm-bundler',
    }
  },
  plugins: [
    new webpack.DefinePlugin({
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false
    })
  ]
}

environment.config.merge(customWebpackConfig)

module.exports = environment
```

(don't forget to restart webpacker when changing this file!)

and then just use `import { whatever } from 'vue'` instead of `import { whatever } from 'vue/dist/vue.esm'`

**Optional: vue3 compat build usage**

- if you're using any vue2 APIs (or one of the libraries you're using), you can use the vue3 compat build
- this enables you to use both vue2 and vue3 APIs and migrate step by step
- usage via webpack config when using webpacker 5.x and up:

`config/webpack/environment.js`
```js
const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

const customWebpackConfig = {
  resolve: {
    alias: {
      vue: '@vue/compat/dist/vue.esm-bundler',
    }
  },
  plugins: [
    new webpack.DefinePlugin({
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false
    })
  ]
}

environment.config.merge(customWebpackConfig)

module.exports = environment
```

# Ruby related changes

## `Matestack::Ui::App` is now called `Matestack::Ui::Layout`

- `Matestack::Ui::App` was always meant to be a layout wrapping pages, but was supercharged with some vuejs logic before splitting the `core` and `vuejs` repos
- now `Matestack::Ui::App` is only a layout, that's why it should be named like that: `Matestack::Ui::Layout`

-> Search&Replace

## `matestack_app` method is renamed to `matestack_layout`

- following the above mentioned naming adjustment, the `matestack_app` method used on controller level is renamed to `matestack_layout`

`app/controllers/demo_controller.rb`
```ruby
class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper

  layout "application" # root rails layout file

  matestack_layout DemoApp::Layout # <-- renamed from matestack_app

  def foo
    render DemoApp::Pages::Foo
  end

end
```

# `Matestack::Ui::Layout` `Matestack::Ui::Page` wrapping DOM structures

- previously, `Matestack::Ui::App` added some wrapping DOM structure around the whole layout and around it's `yield`
- this enabled dynamic page transition and loading state animations
- `Matestack::Ui::Layout` now purely renders the layout and yields a page without anything in between
- the wrapping DOM structres required for dynamic page transitions and loading state animations needs to be added via two new components if you want to use these features via `matestack-ui-vue_js` (see section below!)

`matestack/some/app/layout.rb`
```ruby
class Some::App::Layout < Matestack::Ui::Layout
  def response
    h1 "Demo App"
    main do
      yield
    end
  end
end
```

`matestack/some/app/pages/some_page.rb`
```ruby
class Some::App::Pages::SomePage < Matestack::Ui::Page
  def response
    h2 "Some Page"
  end
end
```

will just render:

```html
<body> <!-- coming from rails layout if specified -->
  <!-- no wrapping DON structure around the layout -->
  <h1>Demo App</<h1>
  <main>
    <!-- page markup without any wrapping DOM structure -->
    <h2>Some Page</h2>
  <main>
</body>
```

## `Matestack::Ui::Layout` adjustments when using `matestack-ui-vue_js`

**only for `matestack-ui-vue_js` users!**

- `Matestack::Ui::Layout` classes are no longer automatically wrapped by a component tag meant to mount the matestack-ui-core-app component on it.
- this has to be done manually via the `matestack_vue_js_app` component, which is more explicit and gives more flexibility
- additionally, the `page_switch` component has to wrap the `yield` in order to support dynamic page transitions

`matestack/some/vue_js/app/layout.rb`
```ruby
class Some::VueJs::App::Layout < Matestack::Ui::Layout

  def response
    h1 "Demo VueJs App"
    matestack_vue_js_app do # <-- this one
      main do
        page_switch do # <-- and this one
          yield
        end
      end
    end
  end

end
```

- using these components will add the original wrapping DOM structres which enables loading state animations
- new `<matestack-component-tempate>` will be rendered coming from these two new components

```html
<body> <!-- coming from rails layout if specified -->
  <div id="matestack-ui"> <!-- coming from rails layout if specified -->
    <h1>Demo VueJs App</h1>
    <matestack-component-tempate> <!-- new tag rendered since 3.0, should not break anything -->
      <div class="matestack-app-wrapper">
        <main>
          <matestack-component-tempate> <!-- new tag rendered since 3.0, should not break anything -->
            <div class="matestack-page-container">
              <div class="matestack-page-wrapper">
                <div> <!--this div is necessary for conditonal switch to async template via v-if -->
                  <div class="matestack-page-root">
                    your page markup
                  </div>
                </div>
              </div>
            </div>
          </matestack-component-tempate>
        </main>
      </div>
    </matestack-component-tempate>
  </div>
</body>
```

## `id="matestack-ui"` element can be removed from rails application layout when only using `matestack-ui-core`

**only for `matestack-ui-vue_js` users!**

- if you only use `matestack-ui-core`, you can remove the `id="matestack-ui"` element
- if you use `matestack-ui-vue_js`, this is still required!

`app/views/layouts/application.html.erb`
```html
<body>
  <div id="matestack-ui"> <!-- you can remove this div with the matestack-ui ID when not using `matestack-ui-vue_js` -->
    <%= yield %>
  </div>
</body>
```

# Vuejs related changes in order to support vue3

**only for `matestack-ui-vue_js` users!**

## `MatestackUiCore` is now `MatestackUiVueJs`

- following the repo/gem split, the Vue.js related libary is now called `MatestackUiVueJs`

-> Search&Replace

## app definition and mount

`javascript/packs/application.js`
```js
import { createApp } from 'vue'
import MatestackUiVueJs from 'matestack-ui-vue_js'

const appInstance = createApp({})

document.addEventListener('DOMContentLoaded', () => {
  MatestackUiVueJs.mount(appInstance) // use this mount method
})
```

## custom component registration

`some/component/file.js`
```js
import MatestackUiVueJs from 'matestack-ui-vue_js'

const myComponent = {
  mixins: [MatestackUiVueJs.componentMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
  data() {
    return {
      foo: "bar"
    };
  },
  mounted(){
    console.log("custom component mounted")
  }
};

export default myComponent
```

`javascript/packs/application.js`
```js
import { createApp } from 'vue'
import MatestackUiVueJs from 'matestack-ui-vue_js'

import myComponent from 'some/component/file.js' // import component definition from source

const appInstance = createApp({})

appInstance.component('my-component', myComponent) // register at appInstance

document.addEventListener('DOMContentLoaded', () => {
  MatestackUiVueJs.mount(appInstance)
})
```

## component template

- For application components, apply `template: MatestackUiVueJs.componentHelpers.inlineTemplate`

`some/component/file.js`
```js
import MatestackUiVueJs from 'matestack-ui-vue_js'

const myComponent = {
  mixins: [MatestackUiVueJs.componentMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate, // this one!
  data() {
    return {
      foo: "bar"
    };
  },
  mounted(){
    console.log("custom component mounted")
  }
};

export default myComponent
```

- Only for core components
  - add import `import componentHelpers from 'some/relative/path/to/helpers'`
  - and then apply `template: componentHelpers.inlineTemplate`

## component scope prefix

- use `vc.` (short for vue component) in order to prefix all properties references or method calls within your vue.js component `response`

`some/component/file.js`
```js
import MatestackUiVueJs from 'matestack-ui-vue_js'

const myComponent = {
  mixins: [MatestackUiVueJs.componentMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
  data() {
    return {
      foo: "bar"
    };
  },
  mounted(){
    console.log(this.foo) // --> bar
    // or:
    console.log(vc.foo) // --> bar
  }
};

export default myComponent
```

```ruby
class Components::MyComponent < Matestack::Ui::VueJsComponent
  vue_name "my-component"

  def response
    div do
      plain "{{foo}}" # --> undefined!
      plain "{{vc.foo}}" # --> bar
    end
  end
end
```

## component $refs

- use `this.getRefs()` instead of `this.$refs`

-> Search&Replace

## component $el

- use `this.getElement()` instead of `this.$el`

-> Search&Replace

## component beforeDestroy hook

- `beforeDestroy` was renamed to `beforeUnmount` within vue3

-> Search&Replace

## $set, Vue.set

- `this.$set` and `Vue.set` are removed in vue3 as they are not longer required for proper reactivity binding
- If you use these methods, use plain JavaScript mutations instead

## Vuex store dependency removed

- previously a Vuex store was required and by default available. Now it's optional
- you can add a store manually following the official Vuex 4.x docs
