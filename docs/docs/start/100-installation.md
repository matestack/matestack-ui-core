# Installation/Update guide

This guide shows you how to add the `matestack-ui-core` gem to an existing Rails application and update it.

## Installation

Add 'matestack-ui-core' to your Gemfile

```ruby
gem 'matestack-ui-core', '~> 1.3'
```

and run

```text
$ bundle install
```

### Matestack folder

Create a folder called 'matestack' in your app directory. All your Matestack apps, pages and components will be defined there.

```text
$ mkdir app/matestack
```

### Controller setup

Add the Matestack helper to your controllers. If you want to make the helpers available in all controllers, add it to your 'ApplicationController' this way:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  #...
end
```

### Conclusion

Now, you are able to create UI components in pure Ruby and use them in your Rails views. Additionally you can substitute Rails views and layouts with Matestack pages and apps.

If you want to use Matestack's optional reactivity features in pure Ruby \(through dynamic Vue.js components such as `form` and `async` or dynamic page transitions\), please follow this [guide](../reactive_components/100-rails_integration.md) to set up the JavaScript parts via AssetPipeline or Webpacker.

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

### JavaScript via AssetPipeline/Sprockets

If you've installed the JavaScript dependecies via AssetPipeline/Sprockets, updating the Ruby gem is enough! Nothing to do here!

### JavaScript via Yarn

If you've installed the JavaScript dependecies via Yarn/Webpacker you need to update the JavaScript assets manually:

In your package.json, change the version number used in the GitHub path referencing the repo of `matestack-ui-core`. This version number have to match the currently installe version of the Ruby Gem of `matestack-ui-core`

`package.json`

```javascript
{
  "name": "xyz",
  "dependencies": {
    // adjust the following path in order to match the Ruby Gem version!
    "matestack-ui-core": "https://github.com/matestack/matestack-ui-core#v1.3.0", 
  }
}
```

and then run:

```bash
yarn install
```

and finally check if the correct version is installed:

```bash
yarn list --pattern "matestack-ui-core"
```

