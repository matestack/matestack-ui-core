# Basic Building Blocks


## Concept

Matestack enables you to write modern user interfaces in pure ruby. Let's take a closer look at how matestacks concept works and what features it offers you. The below graphic shows the conceptual structure of apps, pages and components. 

![Matestack app, pages, components concept](../../images/concept.png)

Apps are similiar to layouts in Rails. Apps wrap pages with provided content, like a top navigation or a sidebar as displayed in the above image. You will always have at least one app in your Rails application, but you can have as much as you want. For example you could have a public app, which wraps your landing, contact, about pages with a top navigation and a private app, which wraps management pages with a sidebar and different top navigation.

As we already mentioned pages it is time to explain them. Pages are similiar to Rails views. A controller action usually renders a view, with matestack a controller action usually renders a page.

Lastly there are components. Components can be compared to Rails partials. They can be used to structure content and define reusable ui parts. In the above image components are represented with a green background. There is one component containing a text block which is reused three times on the page and another component containing a button, which could be reused on other pages. So with components you can create reusable content blocks to structure your ui and keep it dry.
Components can not only be used inside pages, but also in apps and other components.


Apps, pages and components will live in a `matestack` folder inside your `app` directory. Apps, pages and components can be created as you like, but we recommend to namespace apps and pages. Imagine we have an online shop with a shop app and a management app. The corresponding folder structure should look like this:

```sh
app/matestack/
|
└───shop/
│   │   app.rb
│   └───pages/
│   │   │   home.rb
|
└───management/
│   │   app.rb
│   └───pages/
│   │   │   dashboard.rb
```


Having taken a look at the overall concept of matestacks apps, pages and components and how they work together, we can take a deeper look at each one of them.


### Apps

As mentioned above apps wrap pages with provided content. But what advantages to we get from using an app with pages?

Apps can transition between pages corresponding to the same app. What does transition between pages mean? It means that an app can switch between pages without reloading the apps content. For example your navigation will not be reloaded, but only the page content, improving the user experience. With pure Rails views and layouts the browser would do a full reload of the website. With matestack only the content that should change is requested, rendered and replaced asynchronously without a full reload, providing a more app like or single page application like feeling. 

**Creating an app**

Creating an app is easy. Let's create the shop app from the example at the beginning. As mentioned we recommend namespacing your apps and store pages, which in this case means we create our shop app under the namespace shop. Create a file `app/matestack/shop/app.rb` which will contain our app code. 

```ruby
  class Shop::App < Matestack::Ui::App

    def response
      heading text: 'Matestack Shop'
      yield_page
    end

  end
```

Apps need to inherit from `Matestack::Ui::App` and implement a `response` method. The `response` method contains the output which will be rendered. In our case it would add an "h1" saying "Matestack Shop" above the pages. The `yield_page` method determines where inside the app the page would be rendered. `yield_page` enables the app to transition between pages. 

How the call of `heading text: "Matestack Shop"` works will be explained later in this guide.

As you might have read in the [installation](/docs/guides/000-installation/) guide you need to have a rails layout containing a html element with "matestack-ui" as class name. This is required because matestack uses vue.js and we mount to this class name. Because we do not yet support writing "html, head, meta" and other tags that are used outside the body in matestack you need at least one layout file. But we recommend using one layout file for each app.

**Accessing data in apps**

You can access controller instance variables, helpers (for example devise current_user) and all rails helpers that are available in views also in apps.

For example rails routes helper for a navigation.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    div class: 'navigation' do
      transition path: root_path, text: 'Home' 
      transition path: products_path, text: 'Products' 
    end
  end

end
```

How `transition` works in detail will be explained later in this guide. But for now it is enough to say, that it is similiar to a link with the difference that the app transitions to the other route without a website reload.

### Pages

Pages come close to rails views, but give you the ability to transition between them without full website reloads when used with an app.

**Creating a page**

Let's create the home page from the online shop example. Therefore we create a file `app/matestack/shop/pages/home.rb`. 

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

Pages need to inherit from `Matestack::Ui::Page` and like apps implement a `response` method. Within the `response` method we implement our UI which will be rendered when we call `render Shop::Pages::Home`. Our home page will render a "h2" saying "A few products you may like" followed by five sets of "p" and "small" tags containing the product name and price. With matestack you write pure ruby instead of html and therefore can leverage all of rubys and rails features.

Again, how the `heading`, `paragraph` and `small` calls work will be explained later in this guide.

**Advanced page**

Let's create another page, where we will give you an example what you could do because you're writing uis in pure ruby. 

`app/matestack/shop/pages/products/index.rb`

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  def response
    banner do
      heading text: 'New in the matestack shop'
    end
    banner do
      heading text: 'Sale'
      paragrap text: 'Now until tommorow'
    end
    Product.all.each do |product|
      product_teaser product.name, product.price
    end
  end

  private

  def banner(&block)
    div class: 'banner' do
      yield
    end
  end

  def product_teaser(name, price)
    paragraph text: name,
    small text: prive
  end

end
```

The possibilities are endless. Our `banner` method takes in a block and sourrounds it with a "div". This could be useful if you have complex repeating markup which is only relevant on this page and has different content inside. Our `product_teaser(name, price)` methods renders a "p" and "small" tag with the given name and price. But to be clear, we would recommend creating a component for product teaser. You will learn more about components in a second. There is much more you can do. For example inheriting from your own page.

**Accessing data in pages**

As apps, pages have also access to controller instance variables, helpers and rails helpers. For example consider a controller action setting `@highlighted_products`. You can now use it in the page that gets rendered in the same action.

```ruby
class Shop::App < Matestack::Ui::App

  def response
    @highlighted_products.each do |product|
      paragraph text: product.name
      small text: product.price
    end
  end

end
```

### Components

We talked shortly about components and even adviced to create a component for the product teaser, but before doing this we will take a closer look at what components are.

Components are reusable UI parts. They can represent simple parts like a button with specific classes or more complex parts like a product teaser or whatever you think should be a reusable part of your UI. Components are used through method calls which are defined by a component registry. More on that later.

#### Core Components

Above we used methods like `heading`, `paragraph`, `small` and `div`. These are all what we call core components provided trough a core component registry which is automatically loaded. They are components representing the corresponding html tag. For example calling `div` would result after rendering in `<div></div>`. Matestack provides a always expanding wide set of w3c's specified html tags for you, so you could write UIs in pure ruby. All available components are listed in our [components api](/docs/api/100-components/).

There are two different types of core components. Simple components and so called vue.js components. `div` for example is a simple component, it renders a "div" tag either emtpy or containing the content given by a block. `toggle` on the other hand is a vue.js component, because it comes with a corresponding vue.js component to enable dynamic behavior on the client side. `toggle` for example can show or hide content depending on events, enabling you to write such dynamic behavior without writing anything else than ruby.

**Using core components**

Like already mentioned core components are automatically available in apps, pages and components, which means you can right ahead write your UI with apps, pages and components in pure ruby. Just use them like in the examples above. Core components always take a hash as parameter which can contain all corresponding w3c specified html attributes in order to set them. Most components can also take either a `:text` option for their content or a block if they can have nested html content.

```ruby
def response
  div id: 'product-1', class: 'product-teaser', data: { foo: 'bar' } do
    heading text: 'A Product', size: 2
  end
  paragraph text: 'I am a p tag', class: 'highlight text-light'
  span text: 'I am a span', style: 'color: red;'
end
```

Rendered Result:

```html
<div id="product-1" class="product-teaser", data-foo="bar">
  <h1>A product</h1>
</div>
<p class="highlight text-light">I am a p tag</p>
<span style="color: red;">I am a span</span>
```

Most simple core components are callable like their tag name. For example `div` and `span` but some differ from their tag name. `paragraph` for example would overwrite the short version of `puts` (=> `p`) and therefore was named differently. Take a look at the component list in the [components api](/docs/api/000-base/).

#### Creating own components

Components can be used to structure the UI in smaller parts, which may be reusable. Creating a component is as easy as creating apps and pages. Create a file called `teaser.rb` inside `app/matestack/components/products/teaser.rb`. We put our component inside a components folder inside the matestack folder because we may want to reuse this component in both our apps (shop, management). If we knew we will use this component only in our shop, we could have placed it inside our shop folder inside a components folder.

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  def response
    paragraph text: 'Product name placeholder'
    small text: 'Product price placeholder'
  end

end
```

Components need to inherit from `Matestack::Ui::Component` and implement a `response` method. If this component gets called somewhere in a page or app the response method will define the content that gets rendered.

**Using own components**

Now in order to use our product teaser component on our products index page we need to first register the component. We therefore need to create a component registry. We could place it anywhere we want, but we recommend placing it inside the components folder. It is possible to have multiple component registries, for example to keep shop components seperated from management components. Create a file called `registry.rb` in `app/matestack/components/`.

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    product_teaser: Components::Products::Teaser
  )

end
```

We register our product teaser component as `product_teaser`. One last thing remaining in order to use it with `product_teaser` in our pages or apps. We need to include the module in the controller, where we want to use it. So we could include it in our products controller as it would handle the products index action, but we may want to reuse it elsewhere so we include it in our application controller.

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper # see installation guide for details
  include Components::Registry
end
```

After this we can now use our component in our products index page.

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Page

  def response
    Product.all.each do |product|
      product_teaser
    end
  end

end
```

But for know it only renders a "p" and "small" tag with placeholder text for every product. How can we render our product name and price inside the teaser?

**Accessing data in components**

In components you have access to your helpers and all rails helpers. You don't have access to controller instance variables, because components should be reusable everywhere and therefore not depend on instance variables set in controller actions.

To access data inside components we can define required and/or optional properties which are passed to the component via hash and used with getter methods in the component. Our product teaser for example requires a product in order to show its details.

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  requires :product

  def response
    em 'New' if new_product
    paragraph text: product.name
    small text: product.price
  end

end
```

```ruby
class Shop::Pages::Products::Index < Matestack::Ui::Component

  def response
    Product.all.each do |product|
      product_teaser product: product
    end
  end

end
```

So you can pass data via hash to your own components and define them as required (`requires`) or optional (`optional`) properties, which you than can access via a getter method with the property name. It is possible to define multiple required or optional properties at once or call `requires` or `optional` several times in order to define different properties.

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  requires :product, :stock
  requires :image
  optional :highlight, :big_teaser
  optional :disable

  # ...
end
```

If you call a component and forget a required property matestack will throw a `Matestack::Ui::Core::Properties::PropertyMissingException`.

Read more about how properties work and how it prevents overwriting other methods at the [component api](/docs/api/000-base/10-component.md#passing-options-to-components).

#### Creating own vue.js components

For most cases you will not need to create custom vue.js components, but if you need custom javascript behavior you can implement it by using a custom vue.js component. It only differs slightly from components. They also need to implement a `response` method and use properties to access data but they inherit from `Matestack::Ui::VueJsComponent` and require a javascript file implementing the corresponding frontend component. In order to link these they require you to set a vue.js component name. Let's take a look at an example vue.js component:

`app/matestack/components/products/image_slider.rb`

```ruby
class Components::Products::ImageSlider < Matestack::Ui::VueJsComponent
  vue_js_component_name 'products-image-slider'

  requires :images

  def response
    div class: 'image-slider' do
      images.each do |image|
        div class: 'image-slide' do
          img path: image
        end
      end
    end
  end

end
```

We put the necessary vue.js component in the same directory beneath our ruby component. In this file we create our vue component and link it to our ruby component by specifying `vue_js_component_name` inside our ruby component to match the component name we gave our vue component. In this case "products-image-slider".

`app/matestack/components/products/image_slider.js`

```js
MatestackUiCore.Vue.component('products-image-slider', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {
      slide_count: undefined
    }
  },
  methods: {
    //...
  },
  mounted: {
    // ...
  }
})
```

Implementing the javascript component works as you would normally implement your vue.js component. Head over to the [vue.js docs]() to learn more about vue.js. 

To use this component remember to add it like the product teaser to a registry. Also you need to add the javascript file to webpacker or the asset pipeline. To learn how to do that or if you want to know more about vue.js components take a look at the [vue.js component api](/docs/api/000-base/30-vue_js_component.md).


## Event Hub

Matestack uses events as a communication layer to enable features of core vue.js components. It offers an event hub which is accessible to you. Reacting to events in javascript or triggering your own events is therefore possible.

There are some core vue.js components that can react to events and some that can emit events. For example a `toggle` component can be configured to show its content when a certain event appears. Combine it with an `onclick` component which can emit events when its content is clicked and you could create a collapsable content component without writing anything else than ruby.

So reacting to events or triggering them can be done with the core vue.js components. But if you want to react to events or trigger them yourself for example in a custom vue.js component you can do this as shown below.

```js
// use MatestackUiCore.matestackEventHub.$emit(event_name, optional_payload)
// to emit events
MatestackUiCore.matestackEventHub.$emit('my-event', { some: 'optional data' })

// use MatestackUiCore.matestackEventHub.$on(event_name, function)
// to react to events
MatestackUiCore.matestackEventHub.$on('my-event', reactToEvent)
```

Matestack also uses events to give you the option to hook into some processes like page loading and run custom javascript, for example to trigger complex page transition animations, but there is an easier way for simple page transitions animations.

To learn more about the event hub head over to our [event hub api](/docs/api/000-base/50-event_hub.md)


## Core Features

You learned about matestack apps, pages, components, custom components, custom vue.js components, the event hub and you have heard about matestacks core vue.js components. They are vue.js components that implement useful features which would else require you to write javascript. Following up is a short introduction to matestacks unique components that enable you to write rich, modern UIs with ease.

**transition**

Starting off with the `transition` component. The transition component is one of the key components for you to use. You should use them instead of a link if the target path of that link belongs to the same app. Given the example from above, links to our root, products index or details page should be transitions, because they will be rendered in the same app. The use of transitions enables the app to switch between pages without website reloads, instead asynchronously requesting the new page in the background and switching it after a successful response from the server. 

The `transition` component requires a path. Use for example rails routes helpers to provide this. For example:

```ruby
transition path: root_path, text: 'Home'
transition path: products_path, class: 'card-link' do
  div class: 'card' do
    paragraph text: 'Transition with a more complex structure'
  end
end
```

Read more about the [transition component](/docs/guides/400-transitions/README.md).

**onclick**

The `onclick` component is very simple. It can emit an event if the contents of the `onclick` component gets clicked. This component shows its potential when used with other components that can react to events like `toggle`, `async`, `isolated`.

```ruby
onclick emit: 'my-event' do
  button text: 'Click me!'
end
```

Read more about the [onclick component](/docs/api/100-components/onclick.md).

**toggle**

The `toggle` component can toggle its view state according to either events or timers. It can show or hide its content after one of the specified events is received or hide its content after a certain amount of time. You can use it for example to show a notification if a special event occurs and automatically hide the notification after a certain period.  

```ruby
# showing content after 'my-event' was received and hiding it after 2s
toggle show_on: 'my-event', hide_after: 2000 do
  paragraph text: 'Your notification content'
end
```

Read more about the [toggle component](/docs/api/100-components/toggle.md).

**action**

The `action` component can be used to trigger a asynchronous request from for example a button click. Let's assume we want a delete button on our products show page in the management app. Deleting a product would require us to send a DELETE request to the `product_path(product.id)`. The `action` components let's us wrap content which is then clickable and triggers a request with the configured request method to the configured path and with the given params (giving you the ability to add whatever params you want) and let's us react to the server response. It can distinguish between a successful and failed response and emit events, transition somewhere, completely redirect and more for both. You only need to configure it according to your needs.

```ruby
def response
  action action_config do
    button text: 'Delete'
  end
end

def action_config
  {
    path: product_path(product.id),
    method: :delete,
    params: {
      foo: :bar
    },
    sucess: {
      transition: {
        follow_response: true
      }
    },
    failure: {
      emit: 'deletion-failed'
    }
  }
end
```

In the example above, clicking the "Delete" button will trigger an asynchronous DELETE request to the `products_path(id)` with params `foo: :bar`. If successful the action component will trigger a transition to the path the controller redirected us to. If it failed we will emit the "deletion-failed" event. 

We recommend defining the expected hash parameter for `action` components in a method, because they can get quite large.

Read more about the [action component](/docs/guides/600-actions/README.md).

**forms**

Like in Rails with `form_for` you can create a form in matestack with `form`. It takes a hash as parameter with which you can configure your form. In the config hash you can set the HTTP request method, a path, success and failure behavior. You also need to specify a model, string or symbol for what the form is for. All form params will then be submitted nested in this namespace, following Rails behavior and conventions.

```ruby
def response
  form form_config do
    form_input key: :name, type: :text, label: 'Name'
    form_input key: :age, type: :number, label: 'Name'
    textarea key: :description, label: 'Description'
    form_select key: :experience, options: ['Junior', 'Senior']
    form_radio key: :newsletter, options: { 'Yeah, a newsletter.': 1, 'Oh no. Not again.': 0 }, label: 'Name'
    form_checkbox key: :conditions, label: "I've read the terms and conditions"
    form_submit do
      button text: 'Save'
    end
  end
end

def form_config
  {
    for: User.new
    path: users_path,
    method: :post,
    success: {
      transition: {
        follow_redirect: true
      }
    },
    failure: {
      emit: 'user_form_failure'
    }
  }
end
```

Inside a form you can use our form input components `form_input`, `form_textarea`, `form_select`, `form_radio` and `form_checkbox`. Each input component requires a `:key` which represents the params name as which this inputs value get's submitted. It is also possible to specify `:label` in order to create labels for the input on the fly. Some form components can take additional `:options` as a array or hash, which will render a the passed options. For inputs with possible multiple values, like checkboxes or multisecelects, the selected values are submitted in an array, following again Rails behavior. To learn more about the details of each input component take a look at the [form components api](/docs/api/100-components/form.md)

Wrap a button or any markup which should submit the form when clicked in `form_submit`.

Each form requires a few keys for configuration: `:for`, `:path`, `:method`. Like said above, `:for` can reference a active record object or a string/symbol which will be used to nest params in it. `:path` specifies the target path, the form is submitted to with the configured request method in `:method`.

Forms will be submitted asynchronously and in case of errors dynamically extended to show errors belonging to inputs fields, but it is possible to set custom form behavior in success or failure cases. You could transition to another page, follow the redirect from the server as a transition or normal redirect, or emit events to leverage the above mentioned event hub.

To learn more, check out the [form guide](/docs/guides/500-forms/README.md).

**async**

The `async` component can be used to load or reload content asynchronously depending on page initialization or events. Simply wrap your content which you want to render asynchronously inside the `async` component. In order to load the content asynchronously after the initial page load use `defer: true` or pass in a number to delay the defer. To reload content you can use `:rerender_on` with an event name, leveraging the event hub, to reload the content if the specified event occurs. For example rerendering a list of todos beneath the form to create todos to instantly show new created objects. Remember events can also be used with action cable, which you could use for "real time" synchronization.

```ruby
def response
  paragraph text: 'Time when you pressed the button'
  async id: 'current-time', rerender_on: 'update-time' do
    paragraph text: Time.now
  end
  onclick emit: 'update-time' do
    button text: 'Update Time'
  end
end
```

The above code snippet renders initially a paragraph and the current time followed by a button which emits the "update-time" event. The `async` component triggers an asynchronous request when the event is recieved, requesting it's content from the server. The server will respond with only the contents of the `async` components which is then replaced.

Read more about the [action component](/docs/guides/700-async/README.md).

**isolated**

Isolated components work similar to `async` components, but there are a few differences. Isolated components can not be called or used with a block like async, instead you need to create a custom component inheriting from `Matestack::Ui::IsolatedComponent`. Creation of the custom component works similar to other components, except you need to implement an `authorized?` method. This is needed because isolated components are resolved independently, they are not calling your app, page or anything else like `async` does. Therefore they need to resolve all data independently, but can access params to do so. 

So isolated components are resolved completely indepentendly unlike async for which the whole page is executed but only the async block is rendered.

You can of course use every matestack component inside an isolated component, even `async` or another isolated component.

Read more about the [isolated component](/docs/guides/800-isolated/README.md).

**collection**

With the `collection` component you can display active record model or similar collections and add features like filtering, paginating and ordering with ease. Each of these features requires no page reload to take effect, because the `collection` component leverages a `async` component in combination with the event hub to only reload the effected content of the collection. The `collection` component is a bit more complex as it offers a lot of functionality, that's why we will not explain the rudimentary usage here. 

Take a look at the [collection component guide](/docs//guides/900-collection/README.md) to learn how it works and how to use it.
