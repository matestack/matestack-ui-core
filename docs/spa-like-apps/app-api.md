# App API

An app defines a layout within its `response` method and uses the `yield_page` method to yield the content of a page in its layout.

## Use core components

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    heading size: 1, text: "My Example App Layout"
  end

end
```

## Use registered custom components

Imagine having created and registered a custom component `card`. Go ahead and use it on your page:

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def response
    heading size: 1, text: "My Example App Layout"
    # calling your registered card component without using matestack_component helper!
    card title: "hello"
  end

end
```

## Yielding Matestack pages

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

## Transitions between pages without page reload

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

## Transitions between pages with loading element

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

```markup
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

```markup
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

You can use the `loading` class and your loading state element to implement CSS based loading state effects. It may look like this \(scss\):

```css
.matestack-page-container{

  .matestack-page-wrapper {
    opacity: 1;
    transition: opacity 0.2s ease-in-out;

    &.loading {
      opacity: 0;
    }
  }

  .loading-state-element-wrapper{
    opacity: 0;
    transition: opacity 0.3s ease-in-out;

    &.loading {
      opacity: 1;
    }
  }

}
```

For more informations on transitions, visit [transitions](https://github.com/matestack/matestack-ui-core/tree/829eb2f5a7483ef4b78450a5429589ec8f8123e8/docs/apps/400-transitions/README.md)

