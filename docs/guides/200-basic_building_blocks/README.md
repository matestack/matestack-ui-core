# Basic Building Blocks

## Table of contents

1. Concept
   1. Apps
   2. Pages
   3. Components
2. Event System
3. Core Features

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

**Accessing data in pages**
TODO

### Pages

Pages come close to rails views, but give you the ability to transition between them without full website reloads when used with an app.

**Creating a page**

Let's create the home page from the online shop example. Therefore we create a file `app/matestack/shop/pages/home.rb`. 

```ruby
class Shop::Pages::Home < Matestack::Ui::Page

  def response
    heading size: 2, text: 'A few products you may like'
    Products.limit(5).each do |product|
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
    Products.all.each do |product|
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

The possibilities are endless. Our `banner` method takes in a block and sourrounds it with a "div". This could be useful if you have complex repeating markup which is only relevant on this page and has different content inside. Our `product_teaser(name, price)` methods renders a "p" and "small" tag with the given name and price. But to be clear, we would recommend creating a component for product teaser. You will learn more about components in a second. There is much more you can do. For example you can inherit from your own page.

**Accessing data in pages**
TODO

### Components

We talked shortly about components and even adviced to create a component for the product teaser, but before doing this we will take a closer look at what components are.

Components are reusable UI parts. They can represent simple parts like a button with specific classes or more complex parts like a product teaser or whatever you think should be a reusable part of your UI. Components are used through method calls which are defined throug a component registry. More on that later.

**Core Components**

Above we used methods like `heading`, `paragraph`, `small` and `div`. These are all what we call core components provided trough a core component registry which is automatically loaded. They are components representing the corresponding html tag. For example calling `div` would result after rendering in `<div></div>`. Matestack a wide set of w3c's specified html tags for you, so you could write UIs in pure ruby. All available components are listed in our [components api](/docs/api/100-components/).

There are two different types of core components. Simple components and so called vue.js components. `div` for example is a simple component, it renders a "div" tag either emtpy or containing the content given by a block. `toggle` on the other hand is a vue.js component, because it comes with a corresponding vue.js component to enable dynamic behavior on the client side. `toggle` for example can show or hide content depending on events, enabling you to write such dynamic behavior without writing anything else than ruby.

**Using core components**

Like already mentioned core components are automatically available in apps, pages and components, which means you can right ahead write your UI with apps, pages and components in pure ruby. Just use them like in the examples above. Core components always take a hash as parameter which can contain all corresponding w3c specified html attributes in order to set them.

```ruby
def response
  div id: 'product-1', class: 'product-teaser', data: { foo: 'bar' }
  paragraph text: 'I am a p tag', class: 'highlight'
  span text: 'I am a span', style: 'color: red;'
end
```

Most simple core components are callable like their tag name. For example `div` and `span` but some differ from their tag name. `paragraph` for example would overwrite the short version of `puts` `p` and therefore was named differently. Take a look at the component list in the [components api](/docs/api/000-base/).

**Creating own components**

Components can be used to structure the UI in smaller parts, which may be reusable. Creating a component is as easy as creating apps and pages. Create a file called `teaser.rb` inside `app/matestack/components/products/teaser.rb`. We put our component inside a components folder inside the matestack folder because we may want to reuse this component in both our apps (shop, management). If we knew we will use this component only in our shop, we could have placed it inside our shop folder inside a components folder.

```ruby
class Components::Products::Teaser < Matestack::Ui::Component

  def response
    paragraph 'Product name placeholder'
    small 'Product price placeholder'
  end

end
```

Components need to inherit from `Matestack::Ui::Component` and implement a `response` method. If this component gets called somewhere in a page or app the response method will define the content that gets rendered.

**Accessing data in components**
TODO


## Event System

* describe the event system
* what are events used for
* how do you react to events, trigger events

## Core Features

* prebuild vue.js components for usual and advanced functionality

**transition**

**onclick**

**toggle**

**action**

**forms**

**async**

**isolated**

**collection**