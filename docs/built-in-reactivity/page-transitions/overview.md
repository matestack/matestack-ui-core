# Overview

Matestack's `transition` component enables switching between pages without a website reload. It works similar to links, but instead of reloading the complete website, including the layout like Rails usually does, it only asynchronously reloads the page without the app and replaces it dynamically.

The `transition` component is therefore one of the key components for you to use. You should use them instead of a link if the target path of that link belongs to the same app. Given a shopping application with a shop app, links to our root, products index or details page should be transitions, because they belong to the shop app. The use of transitions enables the app to switch between pages without website reloads, instead asynchronously requesting the new page in the background and switching it after a successful response from the server.

Using the `transition` component is pretty straight forward. Let's take the above mentioned shop app as an example and implement it and add a navigation with transitions to the home or products page. `transition`s are ofcourse usable in apps, pages and components.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    nav do
      transition 'Matestack Shop', path: root_path
      transition 'Products', path: products_path
    end
    yield
  end

end
```

Let's add the products page which simply lists all products and adds a transition to their show page for each one.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  def response
    Products.all.each do |product|
      div do
        paragraph product.name
        transition 'Details', path: product_path(product)
      end
    end
  end

end
```

An app defines a layout within its `response` method and uses the `yield_page` method to yield the content of a page in its layout.

## Transitions between pages without page reload

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    h1 "My Example App Layout"
    nav do
      transition path: app_specs_page1_path do
        button "Page 1"
      end
      transition path: app_specs_page2_path do
        button "Page 2"
      end
    end
    main do
      yield
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
      yield 
    end
    #...
  end

  def my_loading_state_slot
    span class: "some-loading-spinner" do
      plain "loading..."
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

## Styling active transitions and it's parents

Styling a transition which is _active_ is simple, because it automatically gets the `active` class on the clientside when the current path equals it's target path. When a sub page of a parent `transition` component is currently active, the parent `transition` component gets a `active-child` class.

{% page-ref page="transition-component-api.md" %}

