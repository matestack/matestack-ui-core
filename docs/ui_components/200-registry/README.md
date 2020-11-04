# Component registry

Since version 1.0.0, components need to be registered in a registry file:

## Custom component registry

Create a registry module like:

`APP_ROOT/app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    #...
    some_component: Some::Component,
    #...
  )

end
```

and make sure to include this module in your base controller like:

```ruby
class ApplicationController < ActionController::Base

  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry

end
```

The registered DSL method `some_component` does NOT have to match namespace
structure of the component class. (but it could if you like to, as shown in the
example above)

*Note*

Please be aware that once the component registry was loaded, the initially
registered dsl_methods are cached. Removing a dsl_method from the registry will
not have an effect until the server gets reloaded. Added dsl_methods however
will be available without having to restart the server.
