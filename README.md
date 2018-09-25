# Basemate::Ui::Core

Create component based, object oriented views. Get dynamic SPA-like behaviour
through integrated vue.js with zero effort.

## Purpose

TODO

## Why Basemate?

TODO

## Current State
This repo is currently under heavy development and should not be used until the
first tested, stable version is released. Please use it only, if you are
onboarded by the Basemate Team. Feel free to reach out :)

First stable release is scheduled for October 2018.

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
without any Basemate Bundle or Theme in charge. Assets are compiled and served
only via sprockets. This makes it very easy to integrate it in a classic Rails
Project without any further dependencies. It is not recommend if you want to
extend Basemate through building your own vue.js components; you should use
Webpacker instead (see: [Setup with Webpacker](#setup-with-webpacker)).

### Gemfile

Add 'basemate-ui-core' to your Gemfile

Gemfile
```ruby
gem 'basemate-ui-core', :git => 'https://github.com/basemate/basemate-ui-core.git'
```

and run bundle install.

### Javascript

Add 'basemate-ui-core' to your application.js

assets/javascript/application.js
```
//= require basemate-ui-core
```

### Basemate Folder

Create a folder called 'basemate' to your app directory. All your Basemate apps,
pages, components will be defined there.

### Include Helper

Include the Basemate Helper to your controllers. If you want to make the helpers
available in all controllers, include it to your 'ApplicationController' like:

app/controllers/application_controller.rb
```ruby
class ApplicationController < ActionController::Base
  include Basemate::Ui::Core::ApplicationHelper
end

```

## Usage

### Create a Basemate Page
Scenario: You want to use a Basemate Page instead of a classic Rails view as a
response for your controller action.
Your setup would be:

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
    responder_for(Website::Home)
  end

end

```

Your Basemate Page:

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
          col do
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
<div class='row'>
  <div class='col'>
    foo
  </div>
  <div class='col'>
    bar
  </div>
</div>
```
Note:
- "row", "col", "plain" are predefined core components
- you can customize the output of the core components (see: [Customize](#customize))
- you can add your own components (see: [Customize](#customize))
- you can use styles from Basemate Themes (see: [Themes](#themes))
- you can use components from Basemate Bundles (see: [Bundles](#bundles))

### Structure your Basemate Page response with partials

If you don't want to define the response of you page in one block, you can use
partials:

You could refactor this:

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
        row center: true do
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

    def row_2
      partial {
        row center: true do
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
        row center: true do
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
### Use a Prepare block to implement page-related business logic

TODO

### Wrap your Basemate Page into a Basemate App for SPA-like behaviour

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
This gives you following, customized output:

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
