# Installation & setup changes

## IE 11 support dropped

- vue3 dropped IE 11 support
- when using babel alongside webpacker, please adjust your package.json or .browserslistrc config in order to exclude IE 11 support:

```json
{
  "name": "my app",
  "...": { },
  "browserslist": [
    "defaults",
    "not IE 11" // <-- important!
  ]
}
```

Otherwise you may encounter issues around `regeneratorRuntime`

## Setup via webpacker

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

# vue.js changes

## app definition and mount

`javascript/packs/application.js`
```js
import { createApp } from 'vue'
import MatestackUiCore from 'matestack-ui-core'

const appInstance = createApp({})

document.addEventListener('DOMContentLoaded', () => {
  MatestackUiCore.mount(appInstance, '#matestack-ui') // use this mount method
})
```

## custom component registration

`some/component/file.js`
```js
import MatestackUiCore from 'matestack-ui-core'

const myComponent = {
  mixins: [MatestackUiCore.componentMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
import MatestackUiCore from 'matestack-ui-core'

import myComponent from 'some/component/file.js' // import component definition from source

const appInstance = createApp({})

appInstance.component('my-component', myComponent) // register at appInstance

document.addEventListener('DOMContentLoaded', () => {
  MatestackUiCore.mount(appInstance, '#matestack-ui')
})
```

## component template

- For application components, apply `template: MatestackUiCore.componentHelpers.inlineTemplate`

`some/component/file.js`
```js
import MatestackUiCore from 'matestack-ui-core'

const myComponent = {
  mixins: [MatestackUiCore.componentMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate, // this one!
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

- use `vc.` or `vueComponent.` in order to prefix all properties references or method calls within your vue.js component `response`

`some/component/file.js`
```js
import MatestackUiCore from 'matestack-ui-core'

const myComponent = {
  mixins: [MatestackUiCore.componentMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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

## component $el

- use `this.getElement()` instead of `this.$el`

## component beforeDestroy hook

- `beforeDestroy` was renamed to `beforeUnmount` within vue3
- Search&Replace if your're using this hook in any of your vue components

## $set, Vue.set

- `this.$set` and `Vue.set` are removed in vue3 as they are not longer required for proper reactivity binding
- If you use these methods, use plain JavaScript mutations instead

# ruby changes

## matestack wrapper method

- removed, app wrapping is done within the app class directly now
