# Rails integration

Matestack apps and pages are connected to Rails through controllers and controller actions. HTTP requests are handled through classic Rails routing and responded through Rails controller actions. Just let the controller action render Matestack page instead of a Rails view at the end. Optionally you can use apps on controller or action level in order to wrap the page with a layout written in pure Ruby.

## Rails layouts still required

Even if a Matestack app defines the layout of the UI, you need a classic Rails layout in order to get things running:

For Example, your `app/views/layouts/shop_layout.html.erb` should look like this:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>My Shop</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag    'application', media: 'all' %>

    <!-- if you are using webpacker: -->
    <%= javascript_pack_tag 'application' %>

    <!-- if you are using the asset pipeline: -->
    <%= javascript_include_tag 'application' %>
  </head>

  <body>
    <div id="matestack-ui">
      <!-- Matestack apps and pages will be yielded here! -->
      <%= yield %>
    </div>
  </body>
</html>
```
You need to add the ID "matestack-ui" to some part of your application layout (or any layout you use). Don't apply the "matestack-ui" id to the body tag.

## Rails controllers referencing Matestack apps and pages

`app/controllers/shop_controller.rb`

```ruby
class ShopController < ApplicationController

  # if not already included
  include Matestack::Ui::Core::ApplicationHelper
  # if custom components are used
  include Components::Registry

  layout "shop_layout" # if it shouldn't be the default application layout

  matestack_app Shop::App # apps are optional!

  def home
    render Shop::Pages::Home
  end

  def product_detail
    render Shop::Pages::Product::Detail
  end

end
```

and something like this in place:

`app/matestack/shop/app.rb`

```ruby
class Shop::App < Matestack::Ui::App

  def response
    heading text: 'Matestack Shop'
    yield_page
  end

end
```

`app/matestack/shop/pages/home.rb`

```ruby
class Shop::Pages::Home < Matestack::Ui::Page

  def response
    heading size: 2, text: 'A few products you may like'
    Product.limit(5).each do |product|
      paragraph text: product.name
      small text: product.price
    end
  end

end
```

`app/matestack/shop/pages/products/detail.rb`

```ruby
class Shop::Pages::Products::Detail < Matestack::Ui::Page

  def prepare
    @product = Product.find(params[:id])
  end

  def response
    heading size: 2, text: @product.name
    paragraph text: product.description
  end

end
```

## Rails routing as you're used to

Just use Rails routing as you're used to. No additional setup required!

```ruby
Rails.application.routes.draw do

  get '/home', to: 'shop#home'
  get '/product_details/:id', to: 'shop#product_details'

end
```
