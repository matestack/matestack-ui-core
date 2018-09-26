# Basemate::Ui::Core

Create component based, object oriented views. Get dynamic SPA-like behaviour
through integrated vue.js with zero effort.

## Purpose

TODO

## Why basemate?

TODO

## Current State
This repo is currently under heavy development and should not be used until the
first tested, stable version is released. Please use it only after being
onboarded by the basemate team. Feel free to reach out if you really can't
wait to start :)

First stable release is scheduled for mid October 2018.

## Table of Contents
1. [Setup](#setup)
2. [Usage](#usage)
3. [Customize](#customize)
4. [Bundles](#bundles)
5. [Themes](#themes)
6. [Contribution](#contribution)
7. [License](#license)

## Setup
This setup part documents the simplest approach to use Basemate::Ui::Core
without any basemate bundle or theme involved. Assets are compiled and served
only via sprockets. This makes it very easy to integrate it in a classic Rails
project without any further dependencies. If you want to extend basemate it is
not recommended to build your own vue.js components; you should use
Webpacker instead (see: [Setup with Webpacker](#setup-with-webpacker)).

### Gemfile

Add 'basemate-ui-core' to your Gemfile

```ruby
gem 'basemate-ui-core', :git => 'https://github.com/basemate/basemate-ui-core.git'
```

and run
````
$ bundle install
````

### Javascript

Require 'basemate-ui-core' in your assets/javascript/application.js

```
//= require basemate-ui-core
```

### Basemate Folder

Create a folder called 'basemate' in your app directory. All your basemate apps,
pages, components (and more to come) will be defined there.

### Include Helper

Add the basemate Helper to your controllers. If you want to make the helpers
available in all controllers, add it to your 'ApplicationController' this way:

app/controllers/application_controller.rb
```ruby
class ApplicationController < ActionController::Base
  include Basemate::Ui::Core::ApplicationHelper
end
```

## Usage

- [Basemate Page](#basemate-page)
  - [Setup](#basic-page-setup)
  - [Partials](#structure-your-basemate-page-response-with-partials)
  - [Prepare Block](#use-the-prepare-method-to-implement-page-related-business-logic)
  - [Iterators](#use-iterators)
- [Basemate App](#basemate-app)
  - [Setup](#basic-app-setup)

### Basemate Page

#### Basic Page Setup
Scenario: You want to use a basemate Page instead of a classic Rails view as a
response for a controller action. This is what your setup looks like:

Your routes:

config/routes.rb
```ruby
Rails.application.routes.draw do
  get '/home', to:'website#home'
end
```

Your Controller Action:

app/controllers/website_controller.rb
```ruby
class WebsiteController < ApplicationController

  def home
    @foo = "foo"
    @bar = "bar"
    responder_for(Website::Home) #-> Basemate::Ui::Core::ApplicationHelper
  end

end
```

Your basemate Page:

app/basemate/website/home.rb
```ruby
module Website
  class Home < Page::Cell::Page

    def response

      components {
        row do
          col do
            plain @foo
          end
          col id: "my_special_col" do
            plain @bar
          end
        end
      }

    end

  end
end
```
This gives you following output:

```html
<div id='website_home'>
  <div class='row' id="row_1">
    <div class='col' id="row_1__col_1">
      foo
    </div>
    <div class='col' id="my_special_col">
      bar
    </div>
  </div>
</div>
```
As you can see, the page is wrapped in a div with an id generated from the
class/module name. These ids get created automatically, but can be overwritten
in the page response. Those ids should help you style specific parts of your
page later on.

Note:
- "row", "col", "plain" are predefined core components
  - a documentation of predefined core component can be found here: TODO
- row/col class setup for bootstrap 4.x and material-design-lite can be found here:
  - bootstrap 4.x: TODO
  - material-design-lite: TODO
- you can customize the output of the core components
  - see: [Customize](#customize)
- you can add your own components
  - see: [Customize](#customize)
- you can use styles from Basemate Themes
  - see: [Themes](#themes)
- you can use components from Basemate Bundles
  - see: [Bundles](#bundles)

#### Structure your basemate Page response with partials

If you don't want to define the response of you page in one block, you can use
partials.

Let's take our app/basemate/website/home.rb and refactor it from this:

```ruby
module Website
  class Home < Page::Cell::Page

    def response

      components {
        row do
          col do
            plain @foo
          end
          col do
            plain @bar
          end
        end
        row do
          col do
            plain "hello"
          end
          col do
            plain "world"
          end
        end
      }

    end

  end
end

```

to this:

```ruby
module Website
  class Home < Page::Cell::Page

    def response
      components {
        partial :row_1
        partial :row_2
      }
    end

    def row_1
      partial {
        row do
          col do
            plain @foo
          end
          col do
            plain @bar
          end
        end
      }
    end

    def row_2
      partial {
        row do
          col do
            plain "hello"
          end
          col do
            plain "world"
          end
        end
      }
    end


  end
end

```

You could also implement dynamic partials, for example:

```ruby
module Website
  class Home < Page::Cell::Page

    def response
      components {
        partial :row, @foo, @bar
        partial :row, "hello", "world"
      }
    end

    def row first_col, second_col
      partial {
        row do
          col do
            plain first_col
          end
          col do
            plain second_col
          end
        end
      }
    end

  end
end

```
#### Use the Prepare method to implement page-related business logic

If you want to move code out of your controller action, you could place your
page-related business logic in the 'prepare'-method of your Basemate Page.


app/controllers/website_controller.rb
```ruby
class WebsiteController < ApplicationController

  def home
    #@foo = "foo" #moved to prepare method
    #@bar = "bar" #moved to prepare method
    responder_for(Website::Home)
  end

end

```

app/basemate/website/home.rb
```ruby
module Website
  class Home < Page::Cell::Page

    def prepare
      @foo = "foo"
      @bar = "bar"
    end

    def response
      components {
        row do
          col do
            plain @foo
          end
          col do
            plain @bar
          end
        end
      }
    end

  end
end

```

#### Use Iterators

Often you need to iterate through some datastructure on your UI. Since you're
writing pure Ruby, it's straight forward. Iterations can use dynamic partials:

app/basemate/website/home.rb
```ruby
module Website
  class Home < Page::Cell::Page

    def prepare
      @team_members = ["Mike", "Laura", "John"]
    end

    def response
      components {
        @team_members.each do |member|
          partial :member_profile, member
        end
      }
    end

    def member_profile member
      partial {
        row do
          col do
            plain member
          end
        end
      }
    end
  end
end

```

### Basemate App

### Basic App Setup

TODO


## Customize

### Customize Core Components

Add a ruby file to the correct basemate customize folder, for example:

app/basemate/customize/ui/core/row.rb
```ruby

module Customize::Ui::Core
  class Row

    def row_classes(classes, options)
      classes << "justify-content-md-center" if options[:center] == true
    end

  end
end
```

and change your Basemate Page to use your new interface:

app/basemate/website/home.rb
```ruby
module Website
  class Home < Page::Cell::Page

    def response

      components {
        row center: true do
          col do
            plain @foo
          end
          col do
            plain @bar
          end
        end
      }

    end

  end
end

```
The result is the following, customized output:

```html
<div class='row justify-content-md-center'>
  <div class='col'>
    foo
  </div>
  <div class='col'>
    bar
  </div>
</div>
```
### Create your own Component

TODO

### Setup with Webpacker

TODO

## Bundles

TODO

## Templates

TODO

## Contribution

### Core

TODO

### Bundles

TODO

### Themes

TODO

## License
The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
