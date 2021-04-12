# Migrating from 1.x to 2.0

## Improvements

* **5 to 12 times better rendering performance \(depending on the context\)**
* **Change to MIT License**
* Core code readability/maintainability --&gt; Enable core contributor team growth
* Vue integration and extenability --&gt; Modern JS workflow and increased flexibility
* Better IDE support --&gt; Removed registry logic enables traceability
* Easier API for component development
* Improved naming schemas
* Reworked docs

## License change

We decided to switch back to the MIT License in order to emphasize that we want to create an Open Source project without any commercial restrictions. We will creat a blog post about that soon!

## Breaking changes

### Trailblazer Cell dependency removed

We did a complete Ruby core rewrite and removed the internal dependencies from `cells`, `haml` and `trailblazer-cells`. We're now using pure Ruby for Matestack's HTML rendering and component based UI structuring. We removed the dependency as we realized that we're just using a small subset of Trailblazer's `cell` feature and are better of when implementing our own business logic. Thank you Trailblazer for bringing us so far!

We only used Trailblazer's `cell` API internally. If you just used the documented API of Matestack, you only need to follow the following migration steps:

### Rails controller

#### Application helper

```ruby
class ApplicationController < ActionController::Base

  # old
  # include Matestack::Ui::Core::ApplicationHelper

  # new
  include Matestack::Ui::Core::Helper

end
```

### Apps

#### yield\_page

* Use `yield` instead of `yield_page`

```ruby
class SomeApp < Matestack::Ui::Component

  def response
    span do
      # old
      # yield_page

      # new
      yield if block_given?
    end
  end

end
```

or if you want to yield in some method other than response:

```ruby
class SomeApp < Matestack::Ui::App

  def response(&block)
    main do
      # old
      # yield_page

      # new
      some_partial(&block)
    end
  end

  def some_partial(&block)
    div do
      yield if block_given?
    end
end
```

#### Loading state element

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    #...
    main do
      # old
      # yield_page slots: { loading_state: my_loading_state_slot }

      # new
      yield if block_given?
    end
    #...
  end

  # old
  # def my_loading_state_slot
  #   slot do
  #     span class: "some-loading-spinner" do
  #       plain "loading..."
  #     end
  #   end
  # end

  # new
  def loading_state_element
    span class: "some-loading-spinner" do
      plain "loading..."
    end
  end

end
```

#### Minimal app wrapping removed

* Until `1.5.0`, `matestack-ui-core` rendered a minimal app around pages without explicitly associated app
* This behavior is removed in `2.0.0` -&gt; a page will be rendered without any wrapping app until an app is explicitly associated

### Pages

**Controller instance variables**

* No more implicit controller instance variable access - &gt; inject like you would inject options into a component

```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    @foo = "bar"
    # old
    # render Pages::SomePage

    # new
    render Pages::SomePage, foo: @foo
  end

end
```

```ruby
class Pages::SomePage < Matestack::Ui::Page

  required :foo

  def response
    plain context.foo # "bar"
  end

end
```

### Components

#### Registry

**Definition**

```ruby
module Components::Registry

  # old
  # Matestack::Ui::Core::Component::Registry.register_components(
  #   some_component: Components::SomeComponent,
  #   # ...
  # )

  # new
  def some_component(text=nil, options=nil, &block)
    Components::SomeComponent.(text, options, &block)
  end

  # ...

end
```

**Usage**

* include your registry in components, pages, and apps directly instead of including it in your controller
* create base classes for apps, pages and components inherting from Matestack's base classes including the registry\(ies\) and let your apps, pages and components inherit from them

As this is just a plain Ruby module, you need to include it in all contexts you want to use the alias method \(unlike the registry prior to 2.0.0\). It's a good idea to create your own ApplicationPage, ApplicationComponent and ApplicationApp as base classes for your pages, components ans apps. In there, you include your component registry module\(s\) only once and have access to the alias methods in all child classes:

```ruby
class ApplicationPage < Matestack::Ui::Page

  include Components::Registry

end

class ApplicationComponent < Matestack::Ui::Component

  include Components::Registry

end

class ApplicationApp< Matestack::Ui::App

  include Components::Registry

end
```

#### Slots

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  # old
  # optional :slots

  # new
  # Do not define any slots as optional or required

  def response
    # old
    # slot slots[:some_slot]

    # new
    slot :some_slot
  end

end
```

```ruby
class Components::SomePage < Matestack::Ui::Page

  def response
    # old
    # some_component slots: { some_slot: some_slot }

    # new
    some_component slots: { some_slot: method(:some_slot) }
  end

  protected

  # old
  # def some_slot
  #   slot do
  #     plain "foo #{bar}"
  #   end
  # end

  # new
  def some_slot
    plain "foo #{bar}"
  end

  def bar
    plain "bar"
  end

end
```

#### Text options

```ruby
class SomePage < Matestack::Ui::Page

  def response
    # old
    # span text: "foo", class: "bar" # still suported for compatibility reasons

    # new
    span "foo", class: "bar"
  end

end
```

#### Required options notation

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  # old
  # requires :foo # still suported for compatibility reasons

  # new
  required :foo

end
```

#### Required/optional options access

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  required :foo
  optional :bar

  # old
  # def response
  #   plain foo
  #   plain options[:foo]
  #   plain bar
  #   plain options[:bar]
  # end

  # new
  def response
    plain context.foo # options[:foo] is not available anymore!
    plain context.bar # options[:bar] is not available anymore!
  end

end
```

#### Required/optional options alias

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  optional class: { as: :bs_class }

  # old
  # def response
  #   span class: bs_class
  # end

  # new
  def response
    span class: context.bs_class
  end

end
```

#### HTML tag attributes

**Definition and rendering on default HTML tags**

* No more whitelisting through explicitly defined HTML ATTRIBUTES
* On default HTML tags, all defined options will be rendered as attributes on that tag

```ruby
class SomePage < Matestack::Ui::Page

  def response
    # old
    # span class: "foo", attributes: { bar: :baz, data: { hello: "world" }}

    # new
    span class: "foo", bar: :baz, data: { hello: "world" }
  end
  # <span class="foo" bar="baz" data-hello="world">

end
```

**Definition and rendering within components**

* No more whitelisting through explicitly defined HTML ATTRIBUTES
* No more access through `html_attributes`, use simple `options` instead

```ruby
class SomePage < Matestack::Ui::Page

  def response
    some_component id: 1, class: "foo", bar: :baz, data: { hello: "world" }
  end
  # <span id=1, class="foo bar" bar="baz" other="foo" data-hello="world" data-foo="bar">

end
```

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  # old
  # def response
  #   span some_processed_attributes
  # end

  # def some_processed_attributes
  #   processed = {}.tap do |attrs|
  #     attrs[:class] = "#{options[:class]} 'bar'",
  #     attrs[:attributes] = { bar: options[:bar], other: :foo, data: options[:data].merge({ foo: "bar" }) }
  #   end
  #   html_attributes.merge(processed)
  # end

  # new
  def response
    span some_processed_attributes
  end

  def some_processed_attributes
    {}.tap do |attrs|
      attrs[:class] = "#{options[:class]} 'bar'",
      attrs[:bar] = options[:bar]
      attrs[:other] = :foo
      attrs[:data] = options[:data].merge({ foo: "bar" })
    end
  end

end
```

#### yield\_components

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  def response
    span do
      # old
      # yield_components
      # new
      yield if block_given?
    end
  end

end
```

or if you want to yield in some method other than response:

```ruby
class Components::SomeComponent < Matestack::Ui::Component

  def response(&block)
    span do
      # old
      # yield_components
      # new
      some_partial(&block)
    end
  end

  def some_partial(&block)
    div do
      yield if block_given?
    end
end
```

### Vue.js

* `matestack-ui-core` does not include prebundle packs for Sprockets anymore
* `MatestackUiCore` is not available in the global window object anymore by default
* Please use the webpacker approach in order to manage and import your JavaScript assets

#### Vue.js integration/mounting

* Within your application pack, you now have to import and mount Vue/Vuex manually

```javascript
// old
// import MatestackUiCore from 'matestack-ui-core'

// new
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

#### Vue.js component definition

```javascript
// old
// MatestackUiCore.Vue.component('some-component', {
//   mixins: [MatestackUiCore.componentMixin],
//   data() {
//     return {};
//   },
//   mounted: function() {

//   },
// });

// new
import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex' // if required
import axios from 'axios' // if required

import MatestackUiCore from 'matestack-ui-core'

Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {};
  },
  mounted: function() {

  },
});
```

#### Vue.js component name helper

```ruby
class Components::SomeComponent < Matestack::Ui::VueJsComponent

  # old
  # vue_js_component_name "some-component"

  # new
  vue_name "some-component"

end
```

#### Vue.js props injection/usage

* No more implicit injection of all options into Vue.js component
* No more `@component_config` instance variable and `setup` method
* Use explicit method in order to inject specific options into Vue.js components

```ruby
class SomePage < Matestack::Ui::Page

  def response
    some_component id: 1, class: "foo", foo: "hello" bar: "world"
  end

end
```

```ruby
class Components::SomeComponent < Matestack::Ui::VueJsComponent

  vue_name "some-component"

  required :bar

  # old
  # all options are implicitly injected and used as vue props
  # or specific vue props through setup method
  # def setup
  #   @component_config[:baz] = "baz"
  # end

  # new
  def vue_props
    {}.tap do |props|
      props[:foo] = options[:foo]
      props[:bar] = context.bar
      props[:baz] = "baz"
    end
  end


end
```

```javascript
Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {};
  },
  mounted: function() {

    // old
    // console.log(this.componentConfig["id"]) // undefined!
    // console.log(this.componentConfig["foo"]) // hello
    // console.log(this.componentConfig["bar"]) // world
    // console.log(this.componentConfig["baz"]) // baz

    // new
    console.log(this.props["id"]) // undefined!
    console.log(this.props["foo"]) // hello
    console.log(this.props["bar"]) // world
    console.log(this.props["baz"]) // baz

  },
});
```

### Form components

#### Root form component name

* renamed `form` to `matestack_form` as `form` is now rendering the HTML form
* `matestack_form` renders the Vue.js driven form as prior to 2.0.0

```ruby
def response
  # old
  # form form_config do

  # new
  matestack_form form_config do
    form_input key: :name, type: :text, label: 'Name'
    # ...
    button "submit", type: :submit
  end
end
```

#### Submit

* `form_submit` component removed, use something like `button 'submit', type: :submit` instead
* get Vue.js form loading state via simple `loading` instead of `loading()`

```ruby
def response
  matestack_form form_config do
    form_input key: :name, type: :text, label: 'Name'
    # ...
    # old
    # form_submit do
    #   button text: "submit"
    # end

    # new
    button "submit", type: :submit

    # and optionally:
    button "submit", type: :submit, "v-if": "!loading"
    button "loading...", type: :submit, disabled: true, "v-if": "loading"
  end
end
```

#### Custom form components

**Base class**

Example for Form Input, adapt all other custom components accordingly:

```ruby
# old
# class Components::MyFormInput < Matestack::Ui::Core::Form::Input::Base

# new
class Components::MyFormInput < Matestack::Ui::VueJs::Components::Form::Input

  # old
  # vue_js_component_name "my-form-input"

  # new
  vue_name "my-form-input"

  # old
  # def prepare
  #   # optionally add some data here, which will be accessible within your Vue.js component
  #   @component_config[:foo] = "bar"
  # end

  # new
  def vue_props
    {
      foo: "bar"
    }
  end

  def response
    # exactly one root element is required since this is a Vue.js component template
    div do
      label text: "my form input"
      input input_attributes.merge(class: "flatpickr")
      render_errors
    end
  end

end
```

### Collection component

#### Helper

```ruby
class SomePage < Matestack::Ui::Page

  # old
  # include Matestack::Ui::VueJs::Components::Collection::Helper

  # new
  include Matestack::Ui::VueJs::Components::Collection::Helper

end
```

#### Filter

* It's now possible to use ALL form child components within a `collection_filter`

```ruby
class SomePage < Matestack::Ui::Page

  # old
  # include Matestack::Ui::VueJs::Components::Collection::Helper

  # new
  include Matestack::Ui::VueJs::Components::Collection::Helper

  def response
    collection_filter @collection.config do
      # old
      # collection_filter_input key: :foo, type: :text, label: 'Text'
      # collection_filter_select key: :buz, options: [1,2,3], label: 'Dropdown'

      # new
      form_input key: :foo, type: :text, label: 'Text'
      form_checkbox key: :bar, label: 'True/False'
      form_checkbox key: :baz, options: [1,2,3], label: 'Multi select via checkboxes'
      form_select key: :buz, options: [1,2,3], label: 'Dropdown'
      #...

      # old
      # collection_filter_submit do
      #   button text: 'Submit'
      # end

      # new
      button 'Submit', type: "submit"

      # same
      collection_filter_reset do
        button 'Reset'
      end
    end
  end

end
```

### Onclick

* changed from rendering a `div` as root element to a `a` tag in order to have an inline root element being consistent with `transition` and `action`

**this possibly breaks the appearance of your UI as we're switching from a block to an inline root element**

```ruby
onclick emit: "hello" do
  button "Klick!"
end
```

will now render:

```markup
<a href="#" class="matestack-onclick-component-root">
  <button>Klick!</button>
</a>
```

instead of:

```markup
<div class="matestack-onclick-component-root">
  <button>Klick!</button>
</div>
```

You can keep the block style by simply applying following styles to your application:

```css
.matestack-onclick-component-root{
  display: block;
}
```

### Link

* link is now calling the HTML `link` tag instead of rendering an `a` tag
* use `a href: ...` or `a path: ...` instead

### Isolate

`isolate` component doesn't raise 'not authorized' anymore. When isolate is not authorized no content is returned. Only a warning is logged to the console

### Rails view

`rails_view` is replaced by `rails_render`. Use `rails_render partial: '/some_partial', locals: { foo: 1 }; rails_render file: '/some_view', locals: { foo: 1 }` to render a partial or a file or anything you want. Use the same as you would use rails `render`

### Component argument

* Pass in text arguments like `header 'Your headline', color: :blue`
* Access it now with `self.text` or `context.text` instead of `@argument`

### Minor HTML rendering changes

* In general: content blocks take precedence over text or :text option
* `area` coords will no longer be automatically joined -&gt; html option does exactly what is expected, no magic
* `italic` and `icon` are now called with the corresponding html tag `i`
* `a` has no more option :path which can take a symbol and renders it with rails url helper. Use :href/:path with or without rails url helper instead
* `unescaped` renamed to `unescape` as it fits the naming conventions more. For example rails html\_escape not html\_escaped. `unescaped` is deprecated now
* `video` has no more magic creation of source tag or automatically fetch asset path to keep dsl as close to html as possible
* removed alias `pg` for `paragraph`
* `transition` can no longer handle symbols as path. Use rails path helper instead
* `Matestack::Ui::DynamicActionviewComponent, Matestack::Ui::Core::Actionview::Dynamic` and static removed -&gt; is not needed

