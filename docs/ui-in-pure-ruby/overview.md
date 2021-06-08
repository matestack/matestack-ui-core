# Overview

## HTML Rendering

Matestack’s rendering mechanism takes care of converting Ruby into HTML:

```ruby
div class: "card shadow-sm border-0 bg-light", foo: "bar" do
  img path: "...", class: "w-100"
  div class: "card-body" do
    h5 "foo", class: "card-title"
    paragraph "bar", class: "card-text"
  end
end
```

will be rendered to:

```markup
<div class="card shadow-sm border-0 bg-light" foo="bar">
  <img src="..." class="w-100">
  <div class="card-body">
    <h5 class="card-title">foo</h5>
    <p class="card-text">bar</p>
  </div>
</div>
```

As you can see, Ruby method calls `like` `div`, `img` ... are mapped to simple HTML tags. `matestack-ui-core` support all kinds of standard HTML tags enabling you to build a well known DOM structure while writing and utilizing pure Ruby!

As you can see, you can add CSS classes and ids as well as custom tag attributes. This way `matestack-ui-core` can be combined with various [CSS frameworks](../integrations/css-frameworks.md) or your custom styles. It’s already fun to write pure Ruby instead of HTML or any other templating engine syntax but this approach is really paying of, when you start using Ruby's language features in order to split your UI implementation into various small chunks, organized through included modules, class inheritance or simply multiple Ruby methods within one class!

The above shown Ruby code lives in Ruby classes inheriting from `Matestack::Ui::Component`, `Matestack::Ui::Page` or `Matestack::Ui::App`

They are described in the next section:

## Basic UI Building Blocks

{% hint style="info" %}
Depending on your desired Rails integration mode \(see below\), you might only need a subset of the now presented building blocks
{% endhint %}

Matestack’s basic UI building blocks are called apps, pages and components:

![](../.gitbook/assets/image%20%282%29.png)

An app can be compared with a Rails layout, a page can be compared with a Rails view and a component can be best compared with a Rails partial.

Apps, pages and components are Ruby classes, implementing a `response` method which will then define specific parts of the UI using pure Ruby methods. We will see in a bit how this looks like.

### Components

Components use Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI. Components can be used on apps, pages and other components. **Additionally they can be used on Rails views \(see below\)**

{% code title="app/matestack/components/card.rb" %}
```ruby
class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      div class: "card-body" do
        heading size: 5, text: context.title if context.title.present?
        paragraph class: "card-text", text: context.body
      end
    end
  end

end
```
{% endcode %}

On the above shown example, a reusable card component was created, which can be used across the whole application taking multiple required or optional options. A component may also take blocks or named slots for flexible markup injection.

Components can be called directly like `Components::Card.(title: "foo", body: "bar")` which will return the desired HTML string. If desired, you can create alias methods in order to avoid the class call syntax:

{% code title="app/matestack/components/registry.rb" %}
```ruby
module Components::Registry

  def card(text=nil, options=nil, &block)
    Components::Card.(text, options, &block)
  end

  #...

end
```
{% endcode %}

which then allows you to call the card component like `card(title: "foo", body: "bar")` if the above shown module is included properly.

Learn more about components:

{% page-ref page="components/" %}

### Pages

As said, a Matestack page can be compared to a Rails view and might be yielded within a layout provided by an associated Matestack app \(see below\). The page itself uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/pages/some\_page.rb" %}
```ruby
class Pages::SomePage < Matestack::Ui::Page

  # optional if you want to use alias methods in order to call your components
  # can be placed in a ApplicationPage class once in order not to include it
  # on every page
  include Components::Registry

  def response
    div class: "container" do
      span id: "hello" do
        plain "hello world!"
      end
      Components::Card.(title: "foo", body: "bar")
      # or (if you created and included the registry module):
      card(title: "foo", body: "bar")
    end
  end

end
```
{% endcode %}

In this basic example the page is using the Ruby methods [`div`](https://github.com/matestack/matestack-ui-core/tree/cde5bfddeb4f2b4ef5808e310731351f020dba69/docs/components-api/core-components/div.md), [`span`](https://github.com/matestack/matestack-ui-core/tree/cde5bfddeb4f2b4ef5808e310731351f020dba69/docs/components-api/core-components/span.md) and [`plain`](https://github.com/matestack/matestack-ui-core/tree/cde5bfddeb4f2b4ef5808e310731351f020dba69/docs/components-api/core-components/plain.md) in order to create the desired UI and call the above defined component `Components::Card`

Pages are used as Rails view substitutes and therefore called in a Rails controller action:

{% code title="app/controllers/some\_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::SomePage
  end

end
```
{% endcode %}

Both the controller and action names will be dynamically added to the `id` attribute of the page's root element, allowing CSS rules to directly target specific pages, and tests to easily locate the page's content.

For example, the above controller code will result in the following HTML markup:

```markup
  <div id="matestack-page-some-controller-overview" class="matestack-page-root">
    <!-- page content -->
  </div>
```

Learn more about Pages:

{% page-ref page="pages/" %}

### Apps

An app uses components in order to define the layout of your application. It might implement a header and a footer for example. Just like a Rails layout would yield a Rails view, an app yields a page. The app uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/some\_app/app.rb" %}
```ruby
class SomeApp::App < Matestack::Ui::App

  def response
    h1 "Some App"
    main do
      yield
    end
  end

end
```
{% endcode %}

In this basic example the app is using the methods `h1` and `main` in order to create the markup as well as a `yield` in order to yield a page on a specific position.

Usually an app implies a specific context of your application. Multiple pages are then scoped within that context, which could lead to a file structure like:

```bash
app/matestack/
|
└───some_app/
│   │   app.rb
│   └───pages/
│   │   │   page1.rb
│   │   │   page2.rb
│   │   │   page3.rb
```

and then used in a controller like this:

{% code title="app/controllers/some\_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  matestack_app SomeApp::App

  def page_1
    render SomeApp::Pages::Page1
  end

  def page_2
    render SomeApp::Pages::Page2
  end

  def page_3
    render SomeApp::Pages::Page3, matestack_app: false # skip app layout on this page
  end

end
```
{% endcode %}

See below \(Full Matestack\) for a more concrete example!

Learn more about Apps:

{% page-ref page="apps/" %}

## Rails Integration Modes

There are several ways to use the presented building blocks in your Rails app. `matestack-ui-core` is designed to be progressively integrated into existing Rails apps and views. Leveraging the full power and beauty is best done when going full Matestack though!

1. **Matestack components on Rails views**

   → Only components are used here and there

2. **Full Matestack**

   → Apps, pages and components used together as a Rails view layer substitute

### **Matestack components on Rails views**

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

### **Full Matestack**

Going full Matestack means, using pages, components and apps as a \(scoped\) complete substitute for the Rails view layer. We're not using Rails views anymore but Matestack pages instead. This behavior is mainly managed within Rails controllers.

{% hint style="info" %}
It's totally valid to serve multiple scopes within one Rails app. Think of a web shop Rails app, consisting of a client-facing storefront UI and a backoffice admin UI. You're free to use full Matestack on one scope and a completely different view layer on the other.
{% endhint %}

Let’s review the classic Rails request/response cycle:

A request is coming in and Rails routing is calling the specified Rails controller action. Nothing new here. Within the Rails action we’re now telling the controller not to render a Rails view wrapped in a Rails layout but instead render a Matestack page wrapped in a Matestack app. All other controller based business logic stays untouched. This is why gems like devise or pundit for example can be used in harmony with `matestack-ui-core`

Thinking of the describe example of a Webshop backoffice admin UI, the implementation with dynamic page transitions may look like this:

{% tabs %}
{% tab title="Routing" %}
```ruby
Rails.application.routes.draw do

  scope :admin do
    get :products, to: 'admin#products'
    get :orders, to: 'admin#orders'
  end

end
```
{% endtab %}

{% tab title="Controller" %}
```ruby
class AdminController < ApplicationController

  include Matestack::Ui::Core::Helper

  matestack_app Admin::App

  def products
    render Admin::Pages::Products
  end

  def orders
    render Admin::Pages::Orders
  end

end
```
{% endtab %}

{% tab title="Admin App" %}
```ruby
class Admin::App < Matestack::Ui::App

  def response
    h1 "Admin App"
    nav do
      transition path: admin_products_page_path do
        button "Products"
      end
      transition path: admin_orders_page_path do
        button "Orders"
      end
    end
    main do
      yield
    end
  end

end
```
{% endtab %}

{% tab title="Products Page" %}
```ruby
class Admin::Pages::Products < Matestack::Ui::Page

  def response
    div class: "container" do
      span id: "hello" do
        plain "products!"
      end
    end
  end

end
```
{% endtab %}

{% tab title="Orders Page" %}
```ruby
class Admin::Pages::Orders < Matestack::Ui::Page

  def response
    div class: "container" do
      span id: "hello" do
        plain "orders!"
      end
    end
  end

end
```
{% endtab %}
{% endtabs %}

In a file structure like:

```bash
app/matestack/
|
└───admin/
│   │   app.rb
│   └───pages/
│   │   │   products.rb
│   │   │   orders.rb
```

