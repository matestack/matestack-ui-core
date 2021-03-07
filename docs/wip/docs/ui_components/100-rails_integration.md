# Rails integration

The easiest way to integrate Matestack is by creating custom components and using our provided `matestack_component(component, options = {}, &block)` helper. Imagine a scenario where we have a product teaser partial in `app/views/products/_teaser.html.erb` containing following content:

```markup
<%= link_to product_path(product), class: 'product-teaser' do %>
  <div>
    <h2><%= product.name %></h2>
    <p><%= product.description %></p>
    <b><%= product.price %></b>
  </div>
<% end %>
```

This is a perfect place to start refactoring our application to use matestack. It's easy to start from the inside out, first replacing parts of your UI with components. As partials already are used to structure your UI in smaller reusable parts they are a perfect starting point. So let's refactor our product teaser into a custom component.

After successfully following the [installation guide](../start/100-installation.md) we can start.

Start by creating a file called `teaser.rb` in `app/matestack/components/products/teaser.rb`. Placement of this file is as you see similar to our partial. In this file we implement our component in pure ruby as follows:

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  requires :product

  def response
    link path: product_path(product), class: 'product-teaser' do
      div do
        heading size: 2, text: product.name
        paragraph text: product.description
        b text: product.price
      end
    end
  end

end
```

We inherit from `Matestack::Ui::Component` to create our teaser component. As it should display product informations it requires a product. We can access this product through a getter method `product`. Now we have now a teaser component, but in order to use it we have to register it and include our registration in our `ApplicationController`.

Let's register our component by creating a component registry in `app/matestack/components/registry.rb`.

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    product_teaser: Components::Products::Teaser
  )

end
```

The last things we have to do before we can use our component is to include our registry in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper # see installation guide for details
  include Components::Registry
end
```

and make Matestack `matestack_component` helper available in views by also including the `Matestack::Ui::Core::ApplicationHelper` in our `ApplicationHelper`.

`app/helpers/application_helper.rb`

```ruby
module ApplicationHelper
  include Matestack::Ui::Core::ApplicationHelper
end
```

Now we can use our Matestack component in our view. Replacing the `render partial:` call from before with a call to `matestack_component` on our landing page.

`app/views/static/index.html.erb`.

```markup
<!-- before -->
<%= render partial: 'products/teaser', collection: @products, as: :product %>

<!-- using our component -->
<%= @products.each do |product| %>
  <%= matestack_component :product_teaser, product: product %>
<% end %>
```

