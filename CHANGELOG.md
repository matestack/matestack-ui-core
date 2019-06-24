# Changelog

## v0.7.0

### Breaking Changes

* new base class names for pages, components and apps, issue #36 (@jonasjabari)
* simplified custom component structure/class names #39 (@jonasjabari)
* improved vue.js component naming convention #41 (@jonasjabari)
* `pg` component is now called `paragraph`, issue #47, pull #48 (@PasWen)

### Migration Guide

#### app base class name

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

#### page base class name

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

#### custom STATIC component base class name / folder structure

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

#### custom DYNAMIC component base class name / folder structure / vue.js naming

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
MatestackUiCore.Vue.component('custom-card', { ... });
```

#### paragraph component

***OLD:***

`app/matestack/pages/example_app/example_page.rb`
```ruby
class Pages::ExampleApp::ExamplePage

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
class Pages::ExampleApp::ExamplePage

  def response
    components {
      paragraph do
        plain "some text"
      end
    }
  end

end
```
### Improvements

* added `hr` component, pull #49, (@michaelrevans)
* allow actions to accept id and class attributes, issue #44, pull #50 (@michaelrevans)


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
