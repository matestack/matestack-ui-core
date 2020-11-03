# SPA-like Apps in pure Ruby

Matestack apps enable you to implement SPA-like web apps utilizing page transitions without any JavaScript required.

## Concept of apps, pages and components

![Matestack app, pages, components concept](../images/concept.png)

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

As you might have read in the [installation](/docs/start/000-installation/) guide you need to have a rails layout containing a html element with "matestack-ui" as class name. This is required because matestack uses Vue.js and we mount to this class name. Because we do not yet support writing "html, head, meta" and other tags that are used outside the body in matestack you need at least one layout file. But we recommend using one layout file for each app.

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
