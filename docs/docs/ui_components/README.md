# UI Components in pure Ruby

Matestack enables you to implement reusable UI components in pure Ruby in order to efficiently build a maintainable UI implementation, utilizing Ruby's amazing language features. A Bootstrap card component may look like this:

`app/matestack/components/card.rb`

```ruby
class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      div class: "card-body" do
        heading size: 5, text: title if title.present?
        paragraph class: "card-text", text: body
      end
    end
  end

end
```

Such a component is defined within your application. We call them custom components. While implementing these, you use Matestack's core components in order to define your UI: Above we used methods like `heading`, `paragraph`, `img` and `div`. These are all what we call core components provided trough a core component registry which is automatically loaded. These core components representing the corresponding HTML tags. Calling `div` for example would result in `<div></div>` after rendering. Matestack provides a always expanding wide set of w3c's specified HTML tags, enabling you to write UIs in pure Ruby. All available components are listed in our [components api](../api/100-components/).

## Component registry

In order to use your custom component we need to register the component. We therefore need to create a component registry. We could place it anywhere we want, but we recommend placing it inside the components folder. It is possible to have multiple component registries, for example to keep shop components seperated from management components. Create a file called `registry.rb` in `app/matestack/components/`.

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    card: Components::Card
  )

end
```

We register our card component as `card`. One last thing remaining in order to use it with `card`: We need to include the module in the controller, where we want to use it. Because we want to use the `card` across the whole app, we include it in our application controller:

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper # see installation guide for details
  include Components::Registry
end
```

## Usage on Rails views

We can now use our components on our Rails views \(and later on on Matestack pages and apps as well\).

`app/views/products/index.html.erb`.

```markup
<%= @products.each do |product| %>
  <%= matestack_component :card, title: product.title, body: product.description, image: product.gallery_image_url %>
<% end %>
```

## Usage on other Matestack components

The registered `card` component can also be used on other registered custom components, skipping the `matestack_component` helper call.

`app/matestack/components/products/detail.rb`

```ruby
class Components::Products::Detail < Matestack::Ui::Component

  requires :product

  def response
    div class: "row" do
      div class: "col" do
       card title: product.title, body: product.description
     end
    end
  end

end
```

## Accessing data in components

In components you have access to your helpers and all Rails helpers. You don't have access to controller instance variables, because components should be reusable everywhere and therefore not depend on instance variables set in controller actions.

To access data inside components we can define required and/or optional properties which are passed to the component via hash and used with getter methods in the component. Our `card` for example requires a body in order to show a minimal Bootstrap card.

