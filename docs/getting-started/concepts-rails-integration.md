# Concepts & Rails Integration

## HTML Structures implemented in pure Ruby

Matestack’s rendering mechanism takes care of converting Ruby into HTML using the core component library. `div`, `span` and `plain` are actually Ruby method calls mapped to a core rendering mechanism responsible for rendering simple HTML tags. `matestack-ui-core` supports all known HTML tags enabling you to build a well known DOM structure while writing and utilizing pure Ruby!

Think of the DOM structure required for a Bootstrap card component:

```markup
<div class="card shadow-sm border-0 bg-light">
  <img src="..." class="w-100">
  <div class="card-body">
    <h5 class="card-title">foo</h5>
    <p class="card-text">bar</p>
  </div>
</div>
```

and now watch the same structure implemented in Ruby:

```ruby
div class: "card shadow-sm border-0 bg-light" do
  img path: "...", class: "w-100"
  div class: "card-body" do
    h5 "foo", class: "card-title"
    paragraph "bar", class: "card-text"
  end
end
```

We're now using pure Ruby in order to create well known HTML structures without any abstraction. Still as flexible as pure HTML but we're now able to use all kind of Ruby's language features in order to structure our UI implementation!

Learn more about Matestack's HTML rendering:

{% page-ref page="../ui-in-pure-ruby/html-rendering.md" %}

But let's see where to put this code first:

{% code title="app/matestack/components/card\_component.rb" %}
```ruby
class Components::CardComponent < Matestack::Ui::Component

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: "...", class: "w-100"
      div class: "card-body" do
        h5 "foo", class: "card-title"
        paragraph "bar", class: "card-text"
      end
    end
  end

end
```
{% endcode %}

We put this code in a self contained Ruby class which we call a **Matestack component.** When a new instance of this class is called, the main response method will return the desired HTML string. Within this Ruby class, we're now able to simply break out of deeply nested HTML structures and create a flat implementation. We end up splitting UI code into small semantically separated chunks.

Doing this we increase readability and maintainability of our implementation:

{% code title="app/matestack/components/card\_component.rb" %}
```ruby
class Components::CardComponent < Matestack::Ui::Component

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: "...", class: "w-100"
      body_partial # calling the below defined instance method
    end
  end

  private

  def body_partial
    div class: "card-body" do
      h5 "foo", class: "card-title"
      paragraph "bar", class: "card-text"
    end
  end

end
```
{% endcode %}

**That’s just a very simple example. Can you imagine how powerful that is when working on complex UIs?**You can use all kinds of Ruby’s language features to craft your HTML structure! Think of shared modules, class inheritance or even meta-programming!

In order to make our component reusable, we define a component API and use injected content like this:

{% code title="app/matestack/components/card\_component.rb" %}
```ruby
class Components::CardComponent < Matestack::Ui::Component

  required :title
  optional :image_path, :content

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image_path, class: "w-100" if context.image_path
      body_partial
    end
  end

  private

  def body_partial
    div class: "card-body" do
      h5 context.title, class: "card-title"
      paragraph context.content, class: "card-text" if context.content
    end
  end

end
```
{% endcode %}

Components may take blocks or even named slots as well, making them even more flexible!

Learn more about components:

{% page-ref page="../ui-in-pure-ruby/components/" %}

But how to integrate this class in a Rails app?

* You can use Matestack components on Rails views
* Or you can use Matestack components on Matestack pages

**Using a Matestack Component on a Rails view:**

{% code title="some\_erb\_file" %}
```markup
<div class="row">
  <% @products.each do |product| %>
    <div class="col-md-3">
      <%= Components::Card.(
        title: product.name,
        content: product.description
      ) %>
    </div>
  <% end %>
</div>
```
{% endcode %}

We simply call our component class and pass in required and optional parameters: in this case title and content coming from a ActiveRecord instance.

**Using a Matestack Component on a Matestack page:**

Alternatively **\*\*we substitute the Rails view with a** Matestack page\*\* and call the component there:

{% code title="app/matestack/pages/product\_overview.rb" %}
```ruby
class Pages::ProductOverview < Matestack::Ui::Page

  def response
    div class: "row" do
      products.each do |product|
        div class: "col-md-3" do
          Components::Card.(
            title: product.name,
            content: product.description
          )
        end
      end
    end
  end

  private

  def products
    Product.last(10) # simple example of using helper methods in your response
  end

end
```
{% endcode %}

In order to integrate this Matestack page into Rails, we're simply telling a Rails controller NOT to render a Rails view, but a Matestack page instead. Matestack can progressively replace or live side by side with the UI layer of Rails - all other concepts like Routing, controller based authentication or authorization and so on stay untouched!

{% code title="app/controllers/products\_controller.rb" %}
```ruby
class ProductsController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::ProductOverview # reference the Page class here
  end

end
```
{% endcode %}

Learn more about Pages:

{% page-ref page="../ui-in-pure-ruby/pages/" %}

That's how we implement HTML structures in pure Ruby and integrate Matestack into Rails!
