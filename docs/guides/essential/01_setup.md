# Essential Guide 1: Setup
Welcome to the first part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In this guide, we will
- create a new Rails application
- install `matestack-ui-core`
- create and render our first 'Hello world' page
- add a simple matestack app, wrap our page and add another one

## Prerequisites
To follow along, make sure you have successfully installed
- Ruby (Version > 2.6, [view installation details](https://www.ruby-lang.org))
- RubyOnRails (Version >6.0, [view installation details](https://rubyonrails.org/))
- Postgresql ([view installation details](https://devcenter.heroku.com/articles/heroku-postgresql#local-setup))


[//]: <> (TODO # maybe remove or rewrite this content block)
The contents of this article are heavily inspired by [Getting Started on Heroku with Rails 6.x](https://devcenter.heroku.com/articles/getting-started-with-rails6), but goes beyond it by introducing the `matestack-ui-core` gem and setting it up with some example content. Both beginners and experienced Ruby/Rails developers should be able to follow along.

## Getting started
In the terminal, create a new Rails app by running

```sh
rails new matestack-demo-application
```

and switch into the newly created project via

```sh
cd matestack-demo-application
```

> Need to create database first

```
rake db:create
```

To make sure things work as expected, you can run

```sh
rails s
```

to start the application. Now visit [localhost:3000](http://localhost:3000/) and you should see the canonical **Yay! You're on Rails!** screen!

## Install Matestack

To install matestack, run `gem install matestack-ui-core` or add `gem 'matestack-ui-core'` to your Gemfile and run `bundle install`.

For a complete setup with Webpacker, you also need to run `yarn add https://github.com/matestack/matestack-ui-core#v1.0.0` followed by `yarn install`.

Then, add

```js
import MatestackUiCore from 'matestack-ui-core'
```

to the `app/javascripts/packs/application.js` and run

```sh
bin/webpack
```

to compile your JavaScript code.

In order to use matestack complete the setup by including the `Matestack::Ui::Core::ApplicationHelper` in your `ApplicationController`. Your `app/controllers/application_controller.rb` should look like this:

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
end
```

And add an element with the id `matestack_ui` to your layout, by changing your `app/views/layouts/application.html.erb`. It should look like this:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>MatestackDemoApplication</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div id="matestack_ui">
      <%= yield %>
    </div>
  </body>
</html>
```

By including the `Matestack::Ui::Core::ApplicationHelper` and defining a div with the `matestack_ui` id you can now use matestacks render method in your controller actions. Based on the id matestack apps and pages can be rendered and pages can be replaced without a full reload of the browser page.

## Create our first page

Apps, Pages and Components will live in a Matestack directory inside your `app` directory. So lets create a directory called `matestack` inside `app`. 

Now lets create our first page featuring the well known "Hello World!" greeting.

Before creating our page we add a root route which calls the `first_page` action of our `DemoController`. Change your `config/routes.rb` and add the following route.

```ruby
Rails.application.routes.draw do
  root to: 'demo#first_page'
end
```

Accordingly to our route we create a new controller called `demo_controller.rb` within `app/controllers/`.

```ruby
class DemoController < ApplicationController

  def first_page
    # later we will render our page here
  end

end
```

Now its time to create our first page. Create a file called `first_page.rb` in `app/matestack/` and add the following content. We will take a closer look at what is happening down below.

```ruby
class FirstPage < Matestack::Ui::Page

  def response
    div do
      plain 'Hello World!'
    end
  end

end
``` 

A page needs to inherit from `Matestack::Ui::Page`. Each page must have a `response` method. The response method should contain your html (written in ruby) which will be displayed when this page gets rendered.

In our `FirstPage` we define the response method and inside call `div` with a block and `plain` with text inside this block. `div` and `plain` are two of many `Matestack::Ui::Components` which you can use to create UI's in Ruby. As you might can imagine the `div` call will render a `<div></div>` and the given block will be rendered inside this div. `plain` renders the given argument plainly. So this response message would look like this in HTML:

```html
<div>
  Hello World!
</div>
```

Okay, so now lets render this page and take a look at it in the browser.

To render a page matestack provides a `render` helper through the module you included earlier in the `ApplicationController`.

Rendering the page is as simple as calling `render FirstPage`. Change your `DemoController` to look like this.

```ruby
class DemoController < ApplicationController

  def first_page
    render FirstPage
  end

end
```

We successfully rendered our first page displaying "Hello World" without writing any HTML code.

## Create our first app

Lets say we want to add a header with navigation links to our first page and upcoming pages. In Rails we would implement this navigation inside our layout, so we don't repeat ourselfs by adding the navigation in every single view. With Matestack we have so called apps which replace the concept of Rails layouts. In order to add a navigation around our page similiar to a rails layout we will create an app called `Demo::App`.
But where to put this app. We recommend you structure your apps and pages as follows:

In our example we want to have a demo app and pages rendered inside this app. That means that `Demo` is our namespace for those. Therefore we put our app and pages inside a folder called `demo`. We move our first page inside this demo folder because it should belong to the demo app. Since we can have many different pages we put all pages in a subfolder called `pages`.

```
app/matestack/
|
└───demo/
│   │   app.rb (`Demo::App`)
│   └───pages/
│   │   │   first_page.rb  (`Demo::Pages::FirstPage`)
```

Because we moved our first page inside `demo/pages` we need to update the class name accordingly, matching the Rails naming conventions. Update the class name of your first page to `Demo::Pages::FirstPage`.

Now we create the demo app by creating a file called `app.rb` inside `app/matestack/demo` and add the following content. We will take a closer look at what is happening down below.

```ruby
class Demo::App < Matestack::Ui::App

  def response
    header do
      heading size: 1, text: 'Demo App'
    end
    main do
      yield_page
    end
  end

end
```

What is happening here. An app needs to inherit from `Matestack::Ui::App` and define a response method like a page. `header, heading, main` are all matestack component helper like `div` which we used in our first page. The `yield_page` call tells the app where the page content should be rendered. In this case inside a `main` tag beneath the `header` tag.

The last thing we need to do in order to render our app around our page is to tell the controller to use the app as a layout. We do this by adding `matestack_app Demo::App` inside our controller, which should now look like this:


```ruby
class DemoController < ApplicationController
  matestack_app Demo::App

  def first_page
    render FirstPage
  end

end
```

If we visit [localhost:3000](http://localhost:3000/) now, we can see that our app is rendered around our first page and the "Hello world!" is shown below the heading "Demo App".

**Create a second page**

In order to better unterstand which advantages and features apps provide, let's create a second page.

First we add a route to our `routes.rb` file.

```ruby
Rails.application.routes.draw do
  root to: 'demo#first_page' 
  get '/second_page' to: 'demo#second_page' 
end
```

Afterwards we create the second page under  `app/matestack/demo/pages` as `second_page.rb` and add some page content.

```ruby
class Demo::Pages::SecondPage < Matestack::Ui::Page

  def response
    div do
      heading size: 1, text: 'I am the second page!'
      paragraph text: "I'm a paragraph on the second page."
    end
  end

end
```

To view our second page we need to add the corresponding controller action `second_page`.

```ruby
class DemoController < ApplicationController
  #...

  def second_page
    render Demo::Pages::SecondPage
  end

end
```

Visit [localhost:3000/second_page](http://localhost:3000/second_page) to view our second page.

### Understanding matestack apps

Now we have two pages which we can only visit via typing in the url. Let's add a navigation above our header to our app in order to navigate between these two pages. We do this like we would normally do it, by adding two links into a _nav_ html tag using matestacks `link` helper. In this step we also add a footer for better understanding of whats happening later.

```ruby
class Demo::App < Matestack::Ui::App

  def response
    nav do
      link path: root_path, text: 'First Page'
      link path: second_page_path, text: 'Second Page'
    header do
      heading size: 1, text: 'Demo App'
    end
    main do
      yield_page
    end
    footer do
      hr
      small text: 'These guides are provided by matestack'
    end
  end

end
```

As you might guess right now, all the method calls like `nav, footer, hr, small` are calls of matestack helpers representing the equivalent html tags.

If we visit [localhost:3000](http://localhost:3000/) now, we see our page with the 'Hello World!' content wrapped by our navigation, header and footer. Clicking the link to the second page, the whole browser page is rerendered and we see our second page. Nothing special here, but matestack provides us with a `transition` helper. Let's take a look at what it does by changing our links to transitions.

```ruby
class Demo::App < Matestack::Ui::App

  def response
    nav do
      transition path: root_path, text: 'First Page'
      transition path: second_page_path, text: 'Second Page'
    header do
      heading size: 1, text: 'Demo App'
    end
    main do
      yield_page
    end
    footer do
      hr
      small text: 'These guides are provided by matestack'
    end
  end

end
```

Again visit [localhost:3000](http://localhost:3000/). Okay now pay close attention to the navigation, header and footer from our app. When you click one of the links generated by the `transition` helper, you should notice that only the page content, in this case the 'Hello World!' gets replaced by the contents of our second page.

matestack `transitions` asynchronously fetch the requested page without the app layout and only replaces the page. Providing a more app like or SPA like behavior. And all you needed to do was creating an app for your pages.

## Commiting the status quo
Let's save the progress so far using Git. In the repo root, run

```sh
git add . && git commit -m "Save basic Rails app with PG and matestack set up"
```

to do that.

## Recap & outlook
We now have a working Rails app using `matestack`.

In this guide we learned how matestack pages work, how we can use matestacks components to create html and how we can use an app as a layout for pages and what benefits we get through using an app. 

After taking a well deserved rest, make sure to continue exploring the features `matestack` offers you by checking out the [next part of the series](/guides/essential/02_active_record.md).
