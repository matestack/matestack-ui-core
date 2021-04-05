# Concepts & Rails Integration

## Basic Concepts

In order to understand how to use Matestack, we should cover some basic concepts first, talking about:

* How is Ruby converted to HTML?
* How can reactivity be implemented in pure Ruby without something like Opal?

### HTML Rendering

Matestack’s rendering mechanism takes care of converting Ruby into HTML using the core component library. `div`, `span` and `plain` are actually Ruby method calls, referencing core component classes `Matestack::Ui::Core::Div`, `Matestack::Ui::Core::Span` and `Matestack::Ui::Core::Plain`. 

As you can see, these basic core components are mapped to simple HTML tags. `matestack-ui-core` ships all kinds of these basic "HTML tag" [components](../components-api/core-components/) enabling you to build a well known DOM structure while writing and utilizing pure Ruby! 

![](../.gitbook/assets/image%20%286%29.png)

As you can see, you can add CSS classes and ids as well as custom tag attributes. This way `matestack-ui-core` can be combined with various [CSS frameworks](../integrations/css-frameworks.md) or your custom styles. It’s already fun to write pure Ruby instead of HTML or any other templating engine syntax but this approach is really paying of, when you start using Ruby's language features in order to split your UI implementation into various small chunks, organized through included modules, class inheritance or simply multiple Ruby methods within one class! 

{% hint style="success" %}
You can create your own component library containing reusable components serving your specific needs in pure Ruby! [Learn more](../ui-components/component-overview.md)
{% endhint %}

### **Vue.js Integration**

{% hint style="info" %}
`matestack-ui-core` can be used without any JavaScript involved! The described Vue.js Integration is optional. You can combine the described HTML Rendering with multiple other reactivity systems if you want!
{% endhint %}

If we use a reactive component, in this example the `form` component and pass in some params like “for”, “path” and “method” as a Ruby hash, Matestack’s rendering mechanism detects that the core component `form` is a special, so called `VueJsComponent`. 

These components consist of two files: The Ruby file with a response method and proper Vue.js JavaScript counterpart file.  `matestack-ui-core` wraps the response of these components in a special `component` HTML tag. Within this tag, the `is` attribute is referencing the Vue.js JavaScript component and the `component-config` attribute contains the parameters we passed into the form. When shipped to the browser, Vue.js will scan the DOM and discover these special HTML component tags. When an appropriate Vue.js JavaScript component is found \(in this case the Vue.js component called `matestack-ui-core-form`\), this Vue.js component gets the specific component-config injected and will be mounted.

\*\*\*\*

![](../.gitbook/assets/image%20%283%29.png)

The core component library contains a growing set of these [Vue.js driven components](../components-api/reactive-core-components/). They enable you to implement a reactive web UI just writing a few lines of Ruby. You’re actually just configuring how prebuilt components should behave in your specific scenario. Behind the scenes it’s just pure Vue.js and no dark magic.

{% hint style="success" %}
It’s super simple to create your own Vue.js driven components if your custom requirements can not be met by core components! [Learn more](../reactivity/custom-vue-js-components.md)
{% endhint %}

### **Vue.js Event System**

Talking about Vue.js driven components brings up one important element of the reactivity system: Events!

Let’s think of the following example: We’re using the reactive `form` component to submit some data and the reactive `async` component in order to rerender a specific part of the UI. The `async` component is also a core VueJs component and will perform a background HTTP request fetching a new version of it’s content at the server. We don’t want to cover the `async` in too much detail, it’s just an example how events are used!

![](../.gitbook/assets/image%20%284%29.png)

After the generated HTML was shipped to the browser and Vue.js mounted all components, the two components are up and running in the web browser. Additionally a Vue.js event hub was mounted. All other components can now emit and receive client side events through that event hub. In our example, we’re configuring the `form` component to emit the event `submitted` when the form was successfully submitted. Furthermore we configured the `async` component to rerender its content when this event is received! This pattern is used for various reactivity features of `matestack-ui-core`

{% hint style="success" %}
Your own Vue.js driven components can also be connected to the event hub and therefore interact with all other components! [Learn more](../reactivity/vuejs-event-hub.md)
{% endhint %}

## Basic UI Building Blocks

Now that we know how Matestack is working under the hood, we should discuss how we can build our UIs with these concepts! Before we review some code, let's start with the basic UI building blocks. 

{% hint style="info" %}
Depending on your desired Rails integration mode \(see below\), you might only need a subset of the now presented building blocks
{% endhint %}

Matestack’s basic UI building blocks are called apps, pages and components. 

An app can be compared with a Rails layout, a page can be compared with a Rails view and a component can be best compared with a Rails partial. 

Apps, pages and components are Ruby classes, implementing a `response` method which will then define specific parts of the UI using pure Ruby methods. We will see in a bit how this looks like.

![](../.gitbook/assets/image%20%282%29.png)

### Components

#### Core Components

`matestack-ui-core` ships all kinds of "HTML-tag" components \(like div, span, ul, li ...\), helping you to create a well know HTML structure in pure Ruby. These components can be used on apps, pages and other components in order to implement an UI. An automatically included core component registry maps Ruby method calls like `div` to the associated Ruby class `Matestack::Ui::Core::Div`

{% page-ref page="../components-api/core-components/" %}

Bundled with `matestack-ui-core` , additionally various Vue.js driven core components enable you to implement **reactive** web UIs in pure Ruby.  

These components can also be used on apps, pages and other components in order to implement an UI.

{% page-ref page="../components-api/reactive-core-components/" %}

#### Custom Components

Custom components may use other core/custom \(reactive\) components in order to define a specific UI. They can be used  on apps, pages and other components if correctly registered in a custom component registry. Additionally they can be used on Rails views \(see below\)

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

On the above shown example, a reusable card component was created, which can used across the whole application.

{% page-ref page="../ui-components/component-overview.md" %}

If you need to implement a very specific reactive feature, you can imlement custom Vue.js components like shown below:

{% tabs %}
{% tab title="Ruby Component" %}
```ruby
class Components::MyVueJsComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "my-vue-js-component"

  def response
    div class: "my-vue-js-component" do
      button attributes: {"@click": "increaseValue"}
      br
      plain "{{ dynamicValue }}!"
    end
  end

end
```
{% endtab %}

{% tab title="Vue.js Component" %}
```javascript
MatestackUiCore.Vue.component('my-vue-js-component', {
  mixins: [MatestackUiCore.componentMixin],
  data: () => {
    return {
      dynamicValue: 0
    };
  },
  methods: {
    increaseValue(){
      this.dynamicValue++
      MatestackUiCore.matestackEventHub.$emit("some_event")
    }
  }
});
```
{% endtab %}
{% endtabs %}

{% page-ref page="../reactivity/custom-vue-js-components.md" %}

### Pages

As said, a Matestack page can be compared to a Rails view and might be yielded within a layout provided by an associated Matestack app \(see below\). The page itself uses components \(core/custom\) in order to define its specific part of the UI.

```ruby
class SomeApp::Pages::SomePage < Matestack::Ui::Page
  
  def response
    div class: "container" do
      span id: "hello" do
        plain "hello world!"
      end
    end
  end
  
end
```

In this basic example the page is using the core components [`div`](../components-api/core-components/div.md), [`span`](../components-api/core-components/span.md) and [`plain`](../components-api/core-components/plain.md) in order to create the desired UI. Learn more about Pages:

{% page-ref page="../spa-like-apps/page-api.md" %}

### Apps

An app uses components in order to define the layout of your application. It might implement a header and a footer for example. Just like a Rails layout would yield a Rails view, an app yields a page. The app uses components \(core/custom\) in order to define the layout.

```ruby
class SomeApp < Matestack::Ui::App
  
  def response
    heading size: 1, text: "Some App"
    main do
      yield_page
    end
  end
  
end
```

In this basic example the app is using the core components [`heading`](../components-api/core-components/heading.md) and [`main`](../components-api/core-components/main.md) and the method`yield_page` in order to yield a page on a specific position. Learn more about Apps:

{% page-ref page="../spa-like-apps/app-api.md" %}

## Rails Integration Modes

There are several ways to use the presented building blocks in your Rails app. `matestack-ui-core` is designed to be progressively integrated into existing Rails apps and views. Leveraging the full power and beauty is best done when going full Matestack though!

1. **Matestack components on Rails views** 

   → Only components are used here and there

2. **Full Matestack** 

   → Apps, pages and components used together as a Rails view layer substitute

### **Matestack components on Rails views**

If you already have plenty of Rails views \(ERB, Haml or Slim\) and want to start creating small UI components in pure Ruby, you are able to use properly registered custom components on these existing views. Within these custom components, you can use all kinds of \(core/custom/reactive\) components. Only the `transition` component will not work without a Matestack app in place

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

The `matestack_component` helper is then used on your Rails view, in this case an ERB view:

```markup
<%= @products.each do |product| %>
  <%= matestack_component :product_teaser, product: product %>
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

In the following example we see a Ruby class called `SomeApp` which is inheriting from `Matestack::Ui::App` and a Ruby class called `SomePage`namespaced in `SomeApp::Pages` inheriting from `Matestack::Ui::Page`.

Using the concepts described above, these two classes will be processed and converted into HTML, ready to be shipped to the browser.

![](../.gitbook/assets/image%20%285%29.png)

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

  include Matestack::Ui::Core::ApplicationHelper

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
    heading size: 1, text: "Admin App"
    nav do
      transition path: admin_products_page_path do
        button text: "Products"
      end
      transition path: admin_orders_page_path do
        button text: "Orders"
      end
    end
    main do
      yield_page
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

Learn more about apps, pages and transitions, in order to create SPA-like apps:

{% page-ref page="../spa-like-apps/spa-overview.md" %}



