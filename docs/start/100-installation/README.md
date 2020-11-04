# Installation guide

This guide shows you how to add matestack-ui-core to an existing rails application.

If you want to use Matestack's optional reactivity features, please follow this [guide](/docs/reactive_components/100-rails-integration/) after performed the following steps for basic installation:

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core', '~> 1.1'
```

and run

```shell
$ bundle install
```

### Matestack folder

Create a folder called 'matestack' in your app directory. All your matestack apps,
pages and components will be defined there.

### Controller setup

Add the matestack helper to your controllers. If you want to make the helpers
available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  #...
end
```
