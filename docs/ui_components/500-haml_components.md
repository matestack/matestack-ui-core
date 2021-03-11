# Haml components

Another way to reuse your existing views and partials are components with _\*.haml_ templates. You can create a component and don't implement a `response` method. In this case, Matestack will look for a _\*.haml_ file right next to it. In this _\*.haml_ file you can access all variables, methods, helpers and so on which you could access in a component. Let's take a closer look by recreating our product teaser component with a _\*.haml_ file. We create a file called `teaser_haml.rb` in `app/matestack/components/products/`.

```ruby
class Components::Products::TeaserHaml < Matestack::Ui::Component

  requires :product

end
```

Next we create the corresponding _\*.haml_ template. As said above, Matestack looks for this template next to the component file. So we will create it in `app/matestack/components/products/teaser_haml.haml`.

```text
= link_to product_path(product), class: 'product-teaser' do
  %div
    %h2= product.name
    %p= product.description
    %b= product.price
```

After registering this component we can use it on Rails views with `matestack_component`. This gives you the opportunity to reuse your views, part of them or partials easily by creating a component and moving your view markup into a _\*.haml_ file next to it. If you are not already using haml in your project checkout [html2haml](https://github.com/haml/html2haml) or many of the available online tools to convert your erb views effortless into _\*.haml_ views.

