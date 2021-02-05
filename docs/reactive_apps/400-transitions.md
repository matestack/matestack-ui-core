# Transitions

Matestack `transition` component enables switching between pages without a website reload. It works similar to links, but instead of reloading the complete website, including the layout like Rails usually does, it only asynchronously reloads the page without the app and replaces it dynamically.

The `transition` component is therefore one of the key components for you to use. You should use them instead of a link if the target path of that link belongs to the same app. Given a shopping application with a shop app, links to our root, products index or details page should be transitions, because they belong to the shop app. The use of transitions enables the app to switch between pages without website reloads, instead asynchronously requesting the new page in the background and switching it after a successful response from the server.

## Usage

Using the `transition` component is pretty straight forward. Let's take the above mentioned shop app as an example and implement it and add a navigation with transitions to the home or products page. `transition`s are ofcourse usable in apps, pages and components.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    nav do
      transition path: root_path, text: 'Matestack Shop'
      transition path: root_path, text: 'Products'
    end
    yield_page
  end

end
```

Let's add the products page which simply lists all products and adds a transition to their show page for each one.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  def response
    Products.all.each do |product|
      div do
        paragraph text: product.name
        transition path: product_path(product), text: 'Details'
      end
    end
  end

end
```

## Styling active transitions and it's parents

Styling a transition which is _active_ is simple, because it automatically gets the `active` class on the clientside when the current path equals it's target path. When a sub page of a parent `transition` component is currently active, the parent `transition` component gets a `active-child` class.

## Complete documentation

If you want to know all details about the `transition` component, like how you can delay it or what events it emits, checkout it's [api documentation](../api/100-components/transition.md)

