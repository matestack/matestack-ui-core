# Rails Integration

Matestacks gives you different options to integrate it into your existing rails project or migrate it step by step to a full matestack app.
In the following sections we will present different methods to integrate or migrate your app, including integrating from the inside out with components first, reusing existing partials and resuse complete views as matestack pages.

All this solutions are going to show you different approaches from which you can choose the appropriate one for you.

In order to explain the following approaches we will shortly describe a scenario. Let's assume a very simple app, which has a landing page, products index page and a products show page. The landing page displays a nav, search bar and 3 product teasers. The products index page lists all components reusing the products teaser partial. The products show page just renders the details of a product.


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
  include ::Rails.application.routes.url_helpers

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

We inherit from `Matestack::Ui::Component` to create our teaser component. As it should display product informations it requires a product. We can access this product through a getter method `product`. To access Rails url helpers we have to include `Rails.application.routes.url_helpers` as components usually get access to them through the pages but we render our component outside a matestack page. Now we have now a teaser component, but in order to use it we have to register it and include our registration in our `ApplicationController`.

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

and make matestack `matestack_component` helper available in views by also including the `Matestack::Ui::Core::ApplicationHelper` in our `ApplicationHelper`.

`app/helpers/application_helper.rb`

```ruby
module ApplicationHelper
  include Matestack::Ui::Core::ApplicationHelper
end
```

Now we can use our matestack component in our view. Replacing the `render partial:` call from before with a call to `matestack_component` on our landing page.

`app/views/static/index.html.erb`.

```html
<!-- before -->
<%= render partial: 'products/teaser', collection: @products, as: :product %>

<!-- using our component -->
<%= @products.each do |product| %>
  <%= matestack_component :product_teaser, product: product %>
<% end %>
```

This approach gives you access inside this component to all matestack features except page transitions. You can use `async`, `toggle`, `collection`, `actions`, `forms`, `isolated`, `onclick` and more Vue.js components inside your components, enabling you to build modern and interactive UIs in pure ruby, while keeping a low effort for integrating or slowly migrating your project to matestack.

To use matestack page transition feature you have to use matestack pages inside a matestack app. 

## Components reusing views or partials

Another method to integrate matestack in your rails application is by reusing your partials with components. Matestack `rails_view` component offers the posssibility to render a view or partial by passing it's name and required params to it. You can either replace your views step by step refactoring them with components which reuse partials and keep the migration of these partials for later or you can reuse a complete view and create a page with a single component rendering the view.

### Components reusing partials

Above we created a new matestack component, recreating our product teaser partial, but instead of doing so we could also reuse this partial with a component. Let's create a matestack page and app, which will list trending products. We add another route `get :trending, to: 'static#trending'` to our `config/routes.rb` file. We create a matestack app in `app/matestack/shop/app.rb`.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    head_section
    yield_page
  end

  private

  def head_section
    header do
      div class: "round-header-background"
      nav do
        div class: "logo" { plain "RAILS" }
      end
      div class: "hero search" do
        heading text: 'Shopping never was easier'
      end
    end
  end
end
```

It displays our header which we used on the other pages too and renders it as an app layout. Below the head section the page will be rendered, specified by the call to `yield_page`.

Now we create our trending page in `app/matestack/pages/trending.rb`. 

```ruby
class Shop::Pages::Trending < Matestack::Ui::Page

  def response
    heading text: 'Trending products'
    main do
      @products.each do |product|
        rails_view partial: 'products/teaser', product: product
      end
    end
  end
  
end
```

As you see we used the `rails_view` component here to render our products teaser partial. Given the string rails searches for a partial in `app/views/products/_teaser.html.erb`. As our product teaser partial uses a `product` we pass in a product. All params except those for controlling the rendering like `:partial` or `:view` get passed to the partial or view as locals. Therefore the partial teaser can access the product like it does. 

To render our trending page within the shop app to see the `rails_view` component working we have to make sure our `app/layouts/application.html.erb` contains an html element with the id "matestack-ui".

```html
<!DOCTYPE html>
<html>
  <head>
    <title>RailsLegacy</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all' %>
    <%= javascript_pack_tag 'application' %>
  </head>

  <body>
    <div id="matestack-ui">
      <%= yield %>
    </div>
  </body>
</html>
```

Lastly we implement the controller action in the `StaticController` which should render our page within our `Shop::App`. We could set the corresponding app by adding a call to `matestack_app Shop::App` at the top of our controller or by using `matestack_app: Shop::App` in our render call. In this example we use the second option.

```ruby
class StaticController < ApplicationController

  def index
    @products = Product.limit(3)
  end
  
  def trending
    @products = Product.limit(3) # our trending products - for simplicity we just select the first three retrieved records
    render Shop::Pages::Trending, matestack_app: Shop::App
  end

end
```

If we now start our rails server with `rails s` and visit [localhost:3000/trending](http://localhost:3000/trending) we can see our `rails_view` component renders our partial with the correct data. 

`rails_view` works with ERB, Haml and Slim Templates. ERB and Haml are supported out of the box. In order to use slim templates the slim gem needs to be installed.

### Components reusing views

As mentioned above the `rails_view` component can not only render partials but also views. You can use this behavior to quickly switch to matestack pages and apps, allowing for page transitions between your views, which enables a more single page application or app like behaviour. Above we introduced our shop app, which we used to wrap our trending products page. We now want to be able to transition between the trending and startpage. Therefore our startpage has to be a matestack page and not a rails view. To simply achieve this we create another page in `app/matestack/shop/pages/` called `index.rb`. 

```ruby
class Shop::Pages::Index < Matestack::Ui::Page

  def response
    rails_view view: 'static/index', products: products
  end

end
```

As we moved the header inside the shop app (but without the form which we will just leave out for simplicity) and our products will not be accessible via instance variable `@products` but instead via the local `products` we need to make slight changes to our view. Removing the header and change all appearances of `@products` to `products`.

```html
<main>
  <%= render partial: 'products/teaser', collection: products, as: :product %>
  <% products.each do |product| %>
    <%= matestack_component :product_teaser, product: product %>
  <% end %>
</main>

<div>
  <%= link_to 'All products', products_path %>
</div>
```

After that we update our `StaticController` in order to render our new page.

`app/controllers/static_controller.rb`

```ruby
class StaticController < ApplicationController
  matestack_app Shop::App
  
  def index
    @products = Product.limit(3)
    render Shop::Pages::Index
  end
  
  def trending
    @products = Product.limit(3)
    render Shop::Pages::Trending
  end

end
```

We moved setting the corresponding app to the top of our controller by calling `matestack_app` instead of specifying it in every render call to keep things dry. We can now visit [localhost:3000](http://localhost:3000) to see our index page working, reusing our old view. 

The next thing we can do is to add transition links to our app to transition between our index and trending page.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    head_section
    yield_page
  end

  private

  def head_section
    header do
      div class: "round-header-background"
      nav do
        div(class: "logo"){ plain "RAILS" }
        div class: 'links' do
          transition path: root_path, text: 'Home'
          transition path: trending_path, text: 'Trending'
        end
      end
      div class: "hero search" do
        heading text: 'Shopping never was easier'
      end
    end
  end
end
```

When we now access [localhost:3000](http://localhost:3000) and click on the trending link and home link, we see how only the content is replaced as those links are now matestack transitions.

So with `rails_view` we can quickly integrate matestack with ease in an existing application and use matestacks transition feature for a more app or single page application like behaviour.

## Custom haml components

Another way to reuse your existing views and partials are components with _*.haml_ templates. You can create a component and don't implement a `response` method. In this case matestack will look for a _*.haml_ file right next to it. In this _*.haml_ file you can access all variables, methods, helpers and so on which you could access in a component. Let's take a closer look by recreating our product teaser component with a _*.haml_ file. We create a file called `teaser_haml.rb` in `app/matestack/components/products/`.

```ruby
class Components::Products::TeaserHaml < Matestack::Ui::Component

  requires :product

end
```

Next we create the corresponding _*.haml_ template. As said above, matestacks looks for this template next to the component file. So we will create it in `app/matestack/components/products/teaser_haml.haml`.

```
= link_to product_path(product), class: 'product-teaser' do
  %div
    %h2= product.name
    %p= product.description
    %b= product.price
```

After registering this component we can use it on our matestack pages or in our rails views with `matestack_render`. This gives you the opportunity to reuse your views, part of them or partials easily by creating a component and moving your view markup into a _*.haml_ file next to it. If you are not already using haml in your project checkout [html2haml](https://github.com/haml/html2haml) or many of the available online tools to convert your erb views effortless into _*.haml_ views.
