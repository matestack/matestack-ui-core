# Hello World Guide

## Getting from zero to one, quickly

*Prerequisite:* We assume you have read and followed the [installation guide](../docs/install), either in a new or existing Rails application.

### Creating your first Matestack app

Within your `app/matestack/` folder, create a folder called `apps` and there,
we will start by adding a file called `my_app.rb`!
Put the following code inside it:

```ruby
class Apps::MyApp < Matestack::Ui::App

  def response
    components {
      header do
        heading size: 1, text: "My App"
      end
      main do
        page_content
      end
    }
  end

end
```

Great! Now we have our first Matestack app inside our Rails application. It can have many pages, and adding a first one is our next step!

### Creating your first Matestack page

Now, within `app/matestack/`, create another folder called `pages/`, and put a folder for our app in it (`my_app`).
In `app/matestack/pages/my_app/`, create a file called `my_example_page.rb` for our first view.

Notice how we describe our User Interface with elements that resemble `HTML tags` - but we can also write Ruby just the way we want to!

```ruby
class Pages::MyApp::MyExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        plain "hello world!"
        5.times do
          br
          plain "Hurray!"
        end
      end
    }
  end

end
```

After creating this example page for our example Matestack app, we're nearly finished. But as you may have guessed, we've yet to prepare the routes and the controller!

### Setting up router and controller

This is straightforward and just works *the Rails way*.

Inside `config/routes.rb`, add a route for the example page:

```ruby
scope :my_app do
  get 'my_example_page', to: 'my_app#my_example_page'
end
```

In `app/controllers/`, create a file called `my_app_controller.rb` and define our *action*:

```ruby
class MyAppController < ApplicationController

  # if it is not already included in the ApplicationController
  # add the Matestack ApplicationHelper here by
  # uncommenting the line below
  # include Matestack::Ui::Core::ApplicationHelper

  def my_first_page
    responder_for(Pages::MyApp::MyFirstPage)
  end
end
```

### Test it

All we got left to do is to start Rails by entering `rails server` in the console and then head to [localhost:3000/my_app/my_example_page](http://localhost:3000/my_app/my_example_page) in our favorite browser!

### Summary

We have successfully installed the `Matestack UI Core gem` to a Rails application and can now write our views in pure Ruby!

Even though we have only seen static content in this hello world example, you may already see the potential in this approach - if not, go ahead and see how we can add client side dynamic with other Matestack components!

## Next steps

Feel invited to check the [other guides](./guides/) for more complex examples or fork our [example application](https://github.com/basemate/matestack-example-application) to start playing around yourself!
