# Rails Integration

Matestacks gives you different options to integrate it into your existing rails project or migrate it step by step to a full matestack app.
In the following sections we will present different methods to integrate or migrate your app, including integrating from the inside out with components first, reusing existing partials and resuse complete views as matestack pages.

All this solutions are going to show you different approaches from which you can choose the appropriate one for you.

In order to explain the following approaches we will shortly describe a scenario. Let's assume a very simple app, which has a landing page, products index page and a products show page. The landing page displays a nav, search bar and 3 product teasers. The products index page lists all components reusing the products teaser partial. The products show page just renders the details of a product.

1. [Custom components](#custom-components)
2. [In progress...](#in-progress)

## Custom components

The easiest way to integrate matestack is by creating custom components and using our provided `matestack_component(component, options = {}, &block)` helper. Given the scenario from above we have a product teaser partial in `app/views/products/_teaser.html.erb` containing following content:

```html
<%= link_to product_path(product), class: 'product-teaser' do %>
  <div>
    <h2><%= product.name %></h2>
    <p><%= product.description %></p>
    <b><%= product.price %></b>
  </div>
<% end %>
```

This is a perfect place to start refactoring our application to use matestack. It's easy to start from the inside out, first replacing parts of your UI with components. As partials already are used to structure your UI in smaller reusable parts they are a perfect starting point. So let's refactor our product teaser into a custom component. 

After successfully following the [installation guide](/docs/guides/000-installation/README.md) we can start. Remember to set the id "matestack-ui" in your corresponding layout. 

Start by creating a file called `teaser.rb` in `app/matestack/components/products/teaser.rb`. Placement of this file is as you see similar to our partial. In this file we implement our component in pure ruby as follows:

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  requires :product

  def response
    link path: product_path(product) do
      div do
        heading size: 2, text: product.name
        paragraph text: product.description
        b text: product.price
      end
    end
  end

end
```

We inherit from `Matestack::Ui::Component` to create our teaser component. As it should display product informations it requires a product. We can access this product through a getter method `product`. We have now a teaser component, but in order to use it we have to register it and include our registration in our `ApplicationController`.

Let's register our component by creating a component registry in `app/matestack/components/registry.rb`. 

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_component{
    product_teaser: Components::Products::Teaser
  }

end
```

The last thing we have to do before we can use our component is to include our registry in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper # see installation guide for details
  include Components::Registry
end
```

Now we can use our matestack component in our view. Replacing the `render partial:` call from before with a call to `matestack_component` on our landing page.

`app/views/static/index.html.erb`.

```html
<!-- before -->
<%= render partial: 'products/teaser', collection: @products, as: :product %>

<!-- using our component -->
<%= @products.each do |product|>
  <%= matestack_component :product_teaser, product: product>
<% end %>
```

This approach gives you access inside this component to all matestack features except page transitions. You can use `async`, `toggle`, `collection`, `actions`, `forms`, `isolated`, `onclick` and more vue.js components inside your components, enabling you to build modern and interactive UIs in pure ruby, while keeping a low effort for integrating or slowly migrating your project to matestack.


## In progress...

![Coming Soon](../../images/coming_soon.png)