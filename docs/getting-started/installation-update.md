# Installation & Update

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core'
```

and run

```
$ bundle install
```

### Matestack folder

Create a folder called `matestack` in your app directory. All your Matestack layouts, pages and components will be defined there.

```
$ mkdir app/matestack
```

### Controller setup

Add the Matestack helper to your controllers. If you want to make the helpers available in all controllers, add it to your `ApplicationController` :

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::Helper
  #...
end
```

Now, you are able to create UI components in pure Ruby and use them in your Rails views. Additionally you can substitute Rails views and layouts with Matestack pages and layouts.

## Update

### Ruby Gem

Depending on the entry in your Gemfile, you might need to adjust the allowed version ranges in order to update the Gem. After checked and adjusted the version ranges, run:

```bash
bundle update matestack-ui-core
```

and then check the installed version:

```bash
bundle info matestack-ui-core
```
