# App

An app defines a layout within its `response` method and uses the `yield_page`
method to yield the content of a page in its layout.

An app is a special kind of `Matestack::Ui::VueJsComponent`. Matestack will
therefore wrap the UI defined in the `response` method with some markup enabling
dynamic UI behavior and CSS styling.

The app ships a `Vuex store` and `Vue.js event hub`, which are used by core vuejs
components and can optionally be used by custom vuejs components in order to
trigger events, manage client side date and communicate between components.

## An App can wrap pages with a layout

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    heading size: 1, text: "My Example App Layout"
    main do
      #yield_page is a core method which yields the page and enables dynamic transitions
      #it can be placed anywhere in your layout
      yield_page
    end
  end

end
```

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page

  def response
    div id: "my-div-on-page-1" do
      heading size: 2, text: "This is Page 1"
    end
  end

end
```

`app/matestack/pages/example_app/second_example_page.rb`

```ruby
class ExampleApp::Pages::SecondExamplePage < Matestack::Ui::Page

  def response
    div id: "my-div-on-page-2" do
      heading size: 2, text: "This is Page 2"
    end
  end

end
```

## An App enables transitions between pages without page reload

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    heading size: 1, text: "My Example App Layout"
    nav do
      transition path: :app_specs_page1_path do
        button text: "Page 1"
      end
      transition path: :app_specs_page2_path do
        button text: "Page 2"
      end
    end
    main do
      yield_page
    end
  end

end
```

The `transition` components will trigger async HTTP requests and exchange the page content without a page reload.

## An App enables transitions between pages without page reload with loading element

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    #...
    main do
      yield_page slots: { loading_state: my_loading_state_slot }
    end
    #...
  end

  def my_loading_state_slot
    slot do
      span class: "some-loading-spinner" do
        plain "loading..."
      end
    end
  end

end
```

which will render:

```html
<main>
  <div class="matestack-page-container">
    <div class="loading-state-element-wrapper">
      <span class="some-loading-spinner">
        loading...
      </span>
    </div>
    <div class="matestack-page-wrapper">
      <div><!--this div is necessary for conditonal switch to async template via v-if -->
        <div class="matestack-page-root">
          your page markup
        </div>
      </div>
    </div>
  </div>
</end>
```

and during async page request triggered via transition:

```html
<main>
  <div class="matestack-page-container loading">
    <div class="loading-state-element-wrapper loading">
      <span class="some-loading-spinner">
        loading...
      </span>
    </div>
    <div class="matestack-page-wrapper loading">
      <div><!--this div is necessary for conditonal switch to async template via v-if -->
        <div class="matestack-page-root">
          your page markup
        </div>
      </div>
    </div>
  </div>
</end>
```

You can use the `loading` class and your loading state element to implement CSS based loading state effects.

For more informations on transitions, visit [transitions](/docs/api/components/transition.md)
