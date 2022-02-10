# Migrating from 2.x to 3.0

## Core/VueJs repo and gem split

* `matestack-ui-core` previously contained logic for
  * Ruby -> HTML conversion
  * Reactivity via prebuilt and custom Vue.js components
* in order to have better seperation of concerns, we've moved the reactivity related things to its own repository/gem -> `matestack-ui-vue_js`
* `matestack-ui-core` is now meant to be combined with any reactivity framework or none at all

{% hint style="warning" %}
**Please follow the migration guide within the docs of `matestack-ui-vuejs` when using reactivity features of `matestack-ui-core` 2.x**
{% endhint %}

## `Matestack::Ui::App` is now called `Matestack::Ui::Layout`

* `Matestack::Ui::App` was always meant to be a layout wrapping pages, but was supercharged with some vuejs logic before splitting the `core` and `vuejs` repos
* now `Matestack::Ui::App` is only a layout, that's why it should be named like that: `Matestack::Ui::Layout`

\-> Search\&Replace

## `matestack_app` method is renamed to `matestack_layout`

* following the above mentioned naming adjustment, the `matestack_app` method used on controller level is renamed to `matestack_layout`

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

\-> Search\&Replace

## `Matestack::Ui::Layout` `Matestack::Ui::Page` wrapping DOM structures

* previously, `Matestack::Ui::App` added some wrapping DOM structure around the whole layout and around it's `yield`
* this enabled dynamic page transition and loading state animations
* `Matestack::Ui::Layout` now purely renders the layout and yields a page without anything in between
* the wrapping DOM structres required for dynamic page transitions and loading state animations needs to be added via two new components if you want to use these features via `matestack-ui-vue_js` (see section below!)

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

\-> Adjust CSS if you have created any rules targeting the wrapping DOM structure which now only is applied when using components from `matestack-ui-vuejs` explicitly
