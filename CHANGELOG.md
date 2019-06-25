# Changelog

## v0.7.0

### Breaking changes for users

* new base class names for pages, components and apps, issue #36 (@jonasjabari)
* simplified custom component structure/class names #39 (@jonasjabari)
* improved vue.js component naming convention #41 (@jonasjabari)
* `pg` component is now called `paragraph`, issue #47, pull #48 (@PasWen)

### Improvements for users

* added `hr` component, pull #49, (@michaelrevans)
* allow actions to accept id and class attributes, issue #44, pull #50 (@michaelrevans)

### Breaking changes for core developers

* namespaced core components using `Matestack::Ui::Core` module/folder, pull #64 (@jonasjabari)
* simplified core components folder structure, (aligned with issue #39), pull #64 (@jonasjabari)
* changed vue.js component naming, (aligned with issue #41), pull #64 (@jonasjabari)
* add-on engine components now need `Matestack::Ui` namespacing, pull #64 (@jonasjabari)

### Improvements for core developers

* started to move business logic out of `app/concepts` into `app/lib` folder in order to create a better structure (in progress --> core refactoring)

### Migration guide for users from v0.6.0

#### App base class name

***OLD:***

`app/matestack/app/example_app.rb`
```ruby
class Apps::ExampleApp < App::Cell::App end
```

***NEW:***

`app/matestack/app/example_app.rb`
```ruby
class Apps::ExampleApp < Matestack::Ui::App end
```

#### Page base class name

***OLD:***

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Page::Cell::Page end
```

***NEW:***

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page end
```

#### Custom STATIC component base class name / folder structure

***OLD:***

`app/matestack/components/card/cell/card.rb`
```ruby
class Components::Card::Cell::Card < Component::Cell::Static end
```

***NEW:***

`app/matestack/components/card.rb`
```ruby
class Components::Card < Matestack::Ui::StaticComponent end
```

#### Custom DYNAMIC component base class name / folder structure / vue.js naming

***OLD:***

`app/matestack/components/card/cell/card.rb`
```ruby
class Components::Card::Cell::Card < Component::Cell::Dynamic end
```

`app/matestack/components/card/cell/card.js`
```javascript
MatestackUiCore.Vue.component('custom-card-cell', { ... });
```

***NEW:***

`app/matestack/components/card.rb`
```ruby
class Components::Card < Matestack::Ui::DynamicComponent end
```

`app/matestack/components/card.js`
```javascript
MatestackUiCore.Vue.component('custom-card', { ... }); //no -cell postfix
```

#### Paragraph component

***OLD:***

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      pg do
        plain "some text"
      end
    }
  end

end
```

***NEW:***

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      paragraph do
        plain "some text"
      end
    }
  end

end
```

### Migration guide for core developers from v0.6.0

If you are not a CORE contributor, this part might not be relevant for you ;)

#### Namespaced core components + simplified core components folder/module structure

The core components are moved from `app/concepts` to `app/concepts/matestack/ui/core` in order to stick to the engine namespacing (used in helpers etc...) and therefore scoped like:

```
app/concepts/matestack/ui/core
|
└───div
│   │   div.rb (no cell folder anymore!)
│   │   div.haml (no view folder anymore!)
```

`app/concepts/matestack/ui/core/div/div.rb`
```ruby
module Matestack::Ui::Core::Div
  class Div < Matestack::Ui::Core::Component::Static


  end
end
```

We also removed the `Cell` module (`cell` folder) and the separate `js` and `view` folders in each component folder in order to simplify folder structure (as we did for custom component development as well)

**Note**

Last module name and class name of CORE components have to be the same. That doesn't apply for CUSTOM components:

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      #CORE
      div
      # looking for 'Matestack::Ui::Core::Div::Div'
      # defined in 'app/concepts/matestack/ui/core/div/div.rb'
      form_input
      # looking for 'Matestack::Ui::Core::Form::Input::Input'
      # defined in 'app/concepts/matestack/ui/core/form/input/input.rb'

      #CUSTOM
      custom_card
      # looking for 'Components::Card'
      # defined in 'app/matestack/components/card.rb'
      custom_fancy_card
      # looking for 'Components::Fancy::Card'
      # defined in 'app/matestack/components/fancy/card.rb'
    }
  end

end
```

The reasons why we decided to resolve core components a bit different than custom components are simple:
* we want to make it as easy as possible to create custom components
  * we therefore removed the obligatory `Cell` module
  * we do not want to force the user to create a subfolder (and therefore module/namespace) in their `components` folder resulting in a class like:
  `Components::Card::Card`. It should be as simple as `Components::Card` which is good and intuitive!
* if we would use that simple approach for all our core components, it would lead to a messy code base, as all component cells, views and javascripts live in one big folder.
  * we therefore enforce more structure inside the core, using a subfolder for each component within `app/concepts/matestack/ui/core` resulting in a class name for a component like: `Matestack::Ui::Core::Div::Div` (double DIV at the end --> subfolder(module name) :: class)

#### Changed vue.js component naming

Scoping all core components within `Matestack::Ui::Core` is reflected in different vue.js component name as well:

Example: `async` core component

`app/concepts/matestack/ui/core/async`
```javascript
//old
Vue.component('async-cell', componentDef)
//new
Vue.component('matestack-ui-core-async', componentDef)
```

We also removed the `-cell` postfix.

#### Add-on-engine component namespacing

Add-on-engine components now need `Matestack::Ui` namespacing:

Example:

```
ADDON_ENGINE_ROOT/app/concepts/matestack/ui/materialize
|
└───row
│   │   row.rb
│   │   row.haml
```

`ADDON_ENGINE_ROOT/app/concepts/matestack/ui/materialize/row/row.rb`
```ruby
module Matestack::Ui::Materialize::Row
  class Row < Matestack::Ui::Core::Component::Static

    def response
      components {
        div class: "row" do
          yield_components
        end
      }
    end

  end
end
```
Usage:

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      #CORE
      div
      # looking for 'Matestack::Ui::Core::Div::Div'
      # defined in 'CORE_ENGINE_ROOT/app/concepts/matestack/ui/core/div/div.rb'

      #ENGINE
      materialize_row
      # looking for 'Matestack::Ui::Materialize::Row::Row'
      # defined in 'ADDON_ENGINE_ROOT/app/concepts/matestack/ui/materialize/row/row.rb'
    }
  end

end
```

## v0.6.0

### Improvements

* added documentation
* added tests

## v0.6.0.pre.1

This release is marked as PRE. Test coverage is not sufficient at the moment.

### Breaking Changes

* Form component now need the ':include' keyword in order to populate the form config to its children
* Input components are now renamed to form_* in order to show their dependency to a parent form component

### Improvements

* partials may now be defined in modules and used across multiple page classes
* components may now define required attributes, which get validated automatically
* components now raises more specific error messages
