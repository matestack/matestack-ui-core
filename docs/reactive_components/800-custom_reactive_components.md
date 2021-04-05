# Custom reactive components

In order to equip a Ruby component with some JavaScript, we associate the Ruby component with a Vue.js JavaScript component. The Ruby component therefore needs to inherit from `Matestack::Ui::VueJsComponent`. Matestack will then render a HTML component tag with some special attributes and props around the response defined in the Ruby component. The Vue.js JavaScript component \(defined in a separate JavaScript file and managed via Sprockets or Webpacker\) will treat the response of the Ruby component as its template.

## Structure, files and registry

A Vue.js component is defined by two files. A Ruby file and a JavaScript file:

### Vue.js Ruby component

Within the Ruby file, the Ruby class inherits from `Matestack::Ui::VueJsComponent`:

`app/matestack/components/some_component.rb`

```ruby
class SomeComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "some-component"

  def response
    div class: "some-root-element" do
      plain "hello {{ foo }}!"
    end
  end

end
```

Following the rule of Vue.js, the response of the component has to consist of exactly one root element! Disregarding this rule will lead to Vue.js errors in the browser.

This Ruby class has to be registered like all other components:

`app/matestack/components/registry.rb`

```ruby
module Components::Registry
  Matestack::Ui::Core::Component::Registry.register_components(
    #...
    some_component: SomeComponent,
    #...
  )
end
```

### Vue.js JavaScript component

The Vue.js JavaScript component is defined in a separate JavaScript file:

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      foo: "bar"
    };
  },
  mounted(){
    console.log(this.foo)
  }
});
```

It can be placed anywhere in your apps folder structure, but we recommend to put it right next to the Ruby component file.

_Important_

The Vue.js JavaScript file needs to be imported by some kind of JavaScript package manager. This could be `Sprockets` or `Webpacker`

For **Sprockets** it would be something like:

`app/assets/javascripts/application.js`

```javascript
//[...]
//= require matestack-ui-core
//= require some_component
//[...]
```

if this is configured correctly:

```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join('app/matestack/components')
```

For **Webpacker** it would look like this:

```javascript
// app/javascript/packs/application.js 
import MatestackUiCore from 'matestack-ui-core'
import '../../../app/matestack/components/some_component'
```

If setup correctly, matestack will render the component to:

```markup
<component is='some-component' :component-config='{}' :params='{}' inline-template>
  <div class="some-root-element">
    hello {{ foo }}!
  </div>
</component>
```

As you can see, the component tag is referencing the Vue.js JavaScript component via `is` and tells the JavaScript component that it should use the inner html \(coming from the `response` method\) as the `inline-template` of the component.

`{{ foo }}` will be evaluated to "bar" as soon as Vue.js has booted and mounted the component in the browser.

Matestack will inject JSON objects into the Vue.js JavaScript component through the `component-config` and `params` props if either component config or params are available. This data is injected once on initial serverside rendering of the component's markup. See below, how you can pass in data to the Vue.js JavaScript component.

## Vue.js Ruby component API

### Same as component

The basic Vue.js Ruby component API is the same as described within the [component API documenation](https://github.com/matestack/matestack-ui-core/tree/829eb2f5a7483ef4b78450a5429589ec8f8123e8/docs/api/000-base/20-component.md). The options below extend this API.

### Referencing the Vue.js JavaScript component

As seen above, the Vue.js JavaScript component name has to be referenced in the Vue.js Ruby component using the `vue_js_component_name` class method

`app/matestack/components/some_component.rb`

```ruby
class SomeComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "some-component"

  #...
end
```

### Passing data to the Vue.js JavaScript component

Like seen above, matestack renders a `component-config` prop as an attribute of the component tag. In order to fill in some date there, you should use the `setup` method like this:

`app/matestack/components/some_component.rb`

```ruby
class SomeComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "some-component"

  def setup
    @component_config[:some_serverside_data] = "bar!"
  end

end
```

This data is then available as:

```javascript
this.componentConfig["some_serverside_data"]
```

within the Vue.js JavaScript component.

## Vue.js JavaScript component API

### Component mixin

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  //...
});
```

Please make sure to integrate the `componentMixin` which gives the JavaScript component some essential functionalities in order to work properly within matestack

### Component config

The JavaScript component can access the serverside injected data like:

```javascript
this.componentConfig["some_serverside_data"]
```

if implemented like

`app/matestack/components/some_component.rb`

```ruby
class SomeComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "some-component"

  def setup
    @component_config[:some_serverside_data] = "bar!"
  end

end
```

### Event Hub

Matestack offers an event hub, which can be used to communicate between components.

#### Emitting events

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {}
  },
  mounted(){
    MatestackUiCore.matestackEventHub.$emit("some-event", { some: "optional data" })
  }
})
```

Use `MatestackUiCore.matestackEventHub.$emit(EVENT_NAME, OPTIONAL PAYLOAD)`

#### Receiving events

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {}
  },
  methods: {
    reactToEvent(payload){
      console.log(payload)
    }
  },
  mounted(){
    MatestackUiCore.matestackEventHub.$on("some-event", this.reactToEvent)
  },
  beforeDestroy: function() {
    matestackEventHub.$off("some-event", this.reactToEvent)
  }
})
```

Make sure to cancel the event listener within the `beforeDestroy` hook!

### Params

If any query params are given in the URL, the JavaScript component can access them via:

```javascript
this.params
```

within the JavaScript component.

### Vue.js API

As we're pretty much implementing pure Vue.js components, you can refer to the [Vue.js guides](https://vuejs.org/v2/guide/) in order to learn more about Vue.js component usage

## Vue.js JavaScript component scope

TODO

