# Reusing views or partials

Another method to integrate Matestack in your rails application is by reusing your partials with components. Matestack `rails_view` component offers the possibility to render a view or partial by passing it's name and required params to it. You can either replace your views step by step refactoring them with components which reuse partials and keep the migration of these partials for later or you can reuse a complete view with a single component rendering this view.

## Components reusing partials

Imagine the partial `app/views/products/_teaser.html.erb` containing following content:

```html
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
    heading text: 'Trending products'
    @products.each do |product|
      rails_view partial: 'products/teaser', product: product
    end
  end

end
```

As you see, we used the `rails_view` component here to render our products teaser partial. Given the string rails searches for a partial in `app/views/products/_teaser.html.erb`. As our product teaser partial uses a `product` we pass in a product. All params except those for controlling the rendering like `:partial` or `:view` get passed to the partial or view as locals. Therefore the partial teaser can access the product like it does.

`rails_view` works with ERB, Haml and Slim Templates. ERB and Haml are supported out of the box. In order to use slim templates the slim gem needs to be installed.

## Components reusing views

As mentioned above the `rails_view` component can not only render partials but also views. Following Rails view can be reused within a Matestack component:

`app/views/static/index.html.erb`

```html
<main>
  <%= render partial: 'products/teaser', collection: products, as: :product %>
</main>

<div>
  <%= link_to 'All products', products_path %>
</div>
```

```ruby
class Components::Products::Index < Matestack::Ui::Component

  def response
    rails_view view: 'static/index', products: products
  end

end
```
