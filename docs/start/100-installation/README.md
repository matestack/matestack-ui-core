# Installation guide

This guide shows you how to add the `matestack-ui-core` gem to an existing Rails application.

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core', '~> 1.2'
```

and run

```shell
$ bundle install
```

### Matestack folder

Create a folder called 'matestack' in your app directory. All your Matestack apps,
pages and components will be defined there.

```shell
$ mkdir app/matestack
```

### Controller setup

Add the Matestack helper to your controllers. If you want to make the helpers
available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  #...
end
```

### Conclusion

Now, you are able to create UI components in pure Ruby and use them in your Rails views. Additionally you can substitute Rails views and layouts with Matestack pages and apps.

If you want to use Matestack's optional reactivity features in pure Ruby (through dynamic Vue.js components such as `form` and `async` or dynamic page transitions), please follow this [guide](/docs/reactive_components/100-rails_integration/) to set up the JavaScript parts via AssetPipeline or Webpacker.
