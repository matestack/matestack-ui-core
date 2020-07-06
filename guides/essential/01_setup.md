# Essential Guide 1: Setup

Welcome to the first part of the 10-step-guide of setting up a working Rails CRUD app with `matestack-ui-core`!

## Introduction
In this guide, we will
- create a new Rails application
- change it to use `postgresql` and `matestack-ui-core`
- add a simple matestack app and two pages
- deploy the application to Heroku

## Prerequisites
To follow along, make sure you have successfully installed
- Ruby (Version > 2.6, [view installation details](https://www.ruby-lang.org))
- RubyOnRails (Version >6.0, [view installation details](https://rubyonrails.org/))
- Heroku CLI ([view installation details](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up))
- Postgresql ([view installation details](https://devcenter.heroku.com/articles/heroku-postgresql#local-setup))

The contents of this article are heavily inspired by [Getting Started on Heroku with Rails 6.x](https://devcenter.heroku.com/articles/getting-started-with-rails6), but goes beyond it by introducing the `matestack-ui-core` gem and setting it up with some example content. Both beginners and experienced Ruby/Rails developers should be able to follow along.

## Getting started

In the terminal, create a new app by running

```sh
rails new matestack-demo-application
```

and switch into the newly created project via

```sh
cd matestack-demo-application
```

To make sure things work as expected, you can run

```sh
rails s
```

to start the application - visiting [localhost:3000](http://localhost:3000/) now should reveal the canonical **Yay! You're on Rails!** screen!

## Adding Postgres and MatestackUiCore

In the Gemfile, replace the line starting with `gem 'sqlite3'` with `gem 'pg'`.
Make sure to run `bundle install` afterwards and replace the contents of `config/database.yml` with

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test

production:
  <<: *default
  database: myapp_production
  username: myapp
  password: <%= ENV['MYAPP_DATABASE_PASSWORD'] %>
```

To install `matestack-ui-core`, add `gem 'matestack-ui-core'` to your Gemfile and run `bundle install`.

For a complete setup with Webpacker, you also need to run `yarn add https://github.com/matestack/matestack-ui-core#v0.7.6` followed by `yarn install`.

Then, add `import MatestackUiCore from 'matestack-ui-core'` to `app/javascripts/packs/application.js` and run

```bin/webpack```

to compile your JavaScript code.

To complete the `matestack-ui-core` setup, change your `app/controllers/application_controller.rb` to look like this

```ruby
class ApplicationController < ActionController::Base
	include Matestack::Ui::Core::ApplicationHelper
end
```

and the `app/views/layouts/application.html.erb` to look like this:

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

Background: You now can use `matestack` helpers in your controller actions, and your `matestack` apps (and the corresponding pages) get rendered into your application layout!

## Add a demo page

Within your `app` directory, create a directory called `matestack` where both *apps* and *pages* will live.
Create a file called `demo_app.rb` in `app/matestack/apps`, and add the following content:

```ruby
class Apps::DemoApp < Matestack::Ui::App

  def response
    components {
      header do
        heading size: 1, text: 'Demo App'
        transition path: :first_page_path, text: 'First page'
        br
        transition path: :second_page_path, text: 'Second page'
      end
      main do
        page_content
      end
    }
  end

end
```

This file provides us with a basic app layout that will stay the same throughout the pages within this app - the header (and other content you may add in the above file) will stay the same, and switching between pages will only replace the `page_content` within the `main`-tag.

Moving on, create two files called `first_page.rb` and `second_page.rb` within `app/matestack/pages/demo_app/`, and add the following content to them:

```ruby
# in app/matestack/pages/demo_app/first_page.rb
class Pages::DemoApp::FirstPage < Matestack::Ui::Page

  def response
    components {
      5.times do
        paragraph text: 'Hello, first page!'
      end
    }
  end

end

# in app/matestack/pages/demo_app/second_page.rb
class Pages::DemoApp::SecondPage < Matestack::Ui::Page

  def response
    components {
      5.times do
        paragraph text: 'Hello, second page!'
      end
    }
  end

end
```

Now, you have two simple matestack pages within your first matestack app, but we're still missing routes and controller actions, so let's quickly add them!

Change your `config/routes.rb` to

```ruby
Rails.application.routes.draw do
  root to: 'demo_app#first_page'

  get '/first_page', to: 'demo_app#first_page'
  get '/second_page', to: 'demo_app#second_page'
end
```

and create a new controller called `demo_app_controller.rb` within `app/controllers/`, using the following content:

```ruby
class DemoAppController < ApplicationController

  def first_page
    responder_for(Pages::DemoApp::FirstPage)
  end

  def second_page
    responder_for(Pages::DemoApp::SecondPage)
  end

end
```

Great! Now, you should be able to run `rails s` once more and, when visiting [localhost:3000](http://localhost:3000/), be greeted with the contents of your first matestack page!

## Commiting the status quo

Let's save the progress so far using Git. In the repo root, run

```sh
git add . && git commit -m "Save basic Rails app with PG and matestack set up"
```

to do that.

## Deployment

To set up a new project, run
```sh
heroku create
```

 followed by

 ```sh
 git push heroku master
 ```

 to trigger the first deployment! After the deployment has successfully finished, you can visit your running application by running

```sh
heroku open
```

## Recap & outlook

You now have a working Rails app using `matestack` not only up and running, but even successfully deployed in the public web - awesome!

After taking a well deserved rest, make sure to continue exploring the features `matestack` offers you by checking out the [next part of the series](/guides/essential/02_active_record.md).
