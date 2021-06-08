# Components on Rails views

If you already have plenty of Rails views \(ERB, Haml or Slim\) and want to start creating small UI components in pure Ruby, you are able to use components on these existing views.

{% code title="app/matestack/components/products/teaser.rb" %}
```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  requires :product

  def response
    a path: product_path(context.product), class: 'product-teaser' do
      div do
        h2 context.product.name
        paragraph conext.product.description
        b context.product.price
      end
    end
  end

end
```
{% endcode %}

The class is then called on your Rails view, in this case an ERB view:

```markup
<%= @products.each do |product| %>
  <%= Components::Products::Teaser.(product: product) %>
<% end %>
```

{% hint style="info" %}
This approach is suitable for existing apps and a good idea to migrate to Matestack step by step. If you start with a blank Rails app, we recommend to go full Matestack right away**!**
{% endhint %}

