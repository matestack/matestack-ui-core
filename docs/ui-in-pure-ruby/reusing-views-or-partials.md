# Reusing Rails Views or Partials

Matestack `rails_render` component offers the possibility to render a view or partial by passing it's name and required params to it

## Components reusing partials

Imagine the partial `app/views/products/_teaser.html.erb` containing following content:

```markup
<%= link_to product_path(product), class: 'product-teaser' do %>
  <div>
    <h2><%= product.name %></h2>
    <p><%= product.description %></p>
    <b><%= product.price %></b>
  </div>
<% end %>
```

```ruby
class Components::Products::Trending < Matestack::Ui::Component

  def prepare
    @products = Product.where(trending: true)
  end

  def response
    h1 'Trending products'
    @products.each do |product|
      rails_render partial: '/products/teaser', locals: { product: product }
    end
  end

end
```

As you see, we used the `rails_render` component here to render our products teaser partial. Given the string rails searches for a partial in `app/views/products/_teaser.html.erb`. As our product teaser partial uses a `product` we pass in a product as a `local`.

`rails_render` works with ERB, Haml and Slim Templates, as long as you have installed and configured the desired templating engine correctly in your Rails app.

## Components reusing views

As mentioned above the `rails_render` component can not only render partials but also views. Following Rails view can be reused within a Matestack component:

`app/views/static/index.html.erb`

```markup
<main>
  <%= render partial: 'products/teaser', collection: products, as: :product %>
</main>

<div>
  <%= link_to 'All products', products_path %>
</div>
```

```ruby
class Components::Products::Index < Matestack::Ui::Component

  def prepare
    @products = Product.where(trending: true)
  end

  def response
    rails_render template: '/static/index', locals: { products: @products }
  end

end
```

