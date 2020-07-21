# Changelog

## v0.8.0 Release

### Improvements

### Bugfixes

### Security fixes

### Migration guide for 0.7.x users

#### `render instead` of `responder_for` in controllers

instead of:

```ruby
class SomeController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def some_page
    responder_for(Pages::SomePage)
  end

end
```

write now:

```ruby
class SomeController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def some_page
    render Pages::SomePage
  end

end
```
The `responder_for` method is still supported but will be removed in a `1.0` release.

**Migration TODOs:**

-[] Replace `responder_for` with `render` in your controllers

#### App/Page structure and namespacing

Until `0.7.x`, matestack-ui-core enforced the user to keep apps and pages in a specific folder structure. An app like `Apps::MyApp` had to be stored in `app/matestack/apps/my_app.rb` and an associated page like `Pages::MyApp::MyPage` lived in `app/matestack/pages/my_app/my_page.rb`. The namespace `Pages::MyApp` determined that the page `MyPage` should be wrapped with the layout coming from `Apps::MyApp`.

We changed this behavior in favor of more intuitive namespacing and more control/flexibility on namespaces and folder structure:

**Flexible folder structure and namespacing of apps and pages**

Apps and pages can now actually live anywhere within your project - we now only recommend best practices (shown further below). The relation between apps and pages is no longer derived from the namespace.

**Explicit app/page relation on controller level**

Within a controller, you can now set the desired `matestack_app` which should wrap all pages used in this controller. This definition is inherited which means, you can set in on an `ApplicationController` and make it a default for all controller and actions.

The "controller-level" `matestack_app` can be overwritten on "action-level" using an additional parameter for the `render` method.

```ruby
class SomeController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app MyApp #default for all action on this controller and inherited ones

  def some_page
    render SomePage
  end

  def some_page_with_other_app
    render SomePage, matestack_app: SomeOtherApp #overwrite controller level matestack_app
  end

  def some_page_with_other_app
    render SomePage, matestack_app: :none #overwrite controller level matestack_app and set to no app at all
  end

end
```

**Default App**

By default matestack-ui-core will render the page wrapped by a minimal default app in order to provide basic app-related features like `transition` and so on.
It is possible to explicitly prevent this behavior.

```ruby
class SomeController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper


  def some_page
    render SomePage #will render with minimal default app if no app is specified on action or controller level
  end

  def some_page_with_no_app
    render SomePage, matestack_app: false #set to no app at all
  end

end
```

**Recommended best practice for app/page folder structure and namespacing**

Imagine your project has two "apps". An "admin" area and a public "website" area. Your folder structure could look like:

```
app/matestack
|
└───admin
│   │   app.rb (`Admin::App < Matestack::Ui::App`)
│   └───pages
│   │   │   dashboard.rb  (`Admin::Pages::Dashboard < Matestack::Ui::Page`)
|
└───website
│   │   app.rb (`Website::App < Matestack::Ui::App`)
│   └───pages
│   │   │   home.rb  (`Website::Pages::Home < Matestack::Ui::Page`)
```

and your corresponding controllers:

`app/controllers/admin_controller.rb`
```ruby
class AdminController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app Admin::App

  before_action :authenticate_admin! # for example

  def dashboard
    render Admin::Pages::Dashboard
  end

end
```

`app/controllers/website_controller.rb`
```ruby
class WebsiteController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app Website::App

  def home
    render Website::Pages::Home
  end

end
```

**Migration TODOs:**

-[] you can keep the `0.7.x` folder structure if you want
-[] just set the related app on your controllers via `matestack_app` as it will no longer be derived automatically from the page namespace

#### Explicit component registration

A major change happened to the component resolving approach. Until `0.7.x` matestack-ui-core automatically translated core component calls like `some_component` to a class like `Matestack::Ui::Core::Some::Component` which had to be defined within the core at `CORE_ROOT/app/concepts/matestack/ui/core/some/component.rb`. Same applied for custom component calls like `custom_my_component` which resolved to a class `Components::My::Component` which had to be defined within the users application at `APP_ROOT/app/matestack/components/my/component.rb`

This auto resolving was completely removed in the `0.8.0` release. All components (core, custom and add-on-engine) have to be registered explicitly as described below:

*Core components*

`CORE_ROOT/lib/matestack/ui/core/components.rb`
```ruby
module Matestack::Ui::Core::Components
  #...
  require_core_component "some/new/component"
  #...
end

Matestack::Ui::Core::Component::Registry.register_components(
  #...
  some_new_component: Matestack::Ui::Core::Some::New::Component,
  #...
)
```

The registered DSL method `some_new_component` does not have to match the components namespace structure.

*Custom components*

Create a registry module like:

`APP_ROOT/app/matestack/components/registry.rb`
```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    #...
    my_component: Components::MyOwnComponent,
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

The registered DSL method `my_component` does not have to match the components namespace structure.

TBD:

Please be aware that once the component registry was loaded, the initially registered dsl_methods are cached. Removing a dsl_method from the registry will not have an effect until the server gets reloaded. Added dsl_methods however will be available without server restart.

*AddOn engine component*

TODO

#### Dynamic component vuejs component names

*Core components*

Until `0.8.0` dynamic core components created the vuejs component name automatically derived from their class name. `Matestack::Ui::Core::Collection::Filter::Filter` for example was translated to a vuejs componente name `matestack-ui-core-collection-filter`. The two occurrences of `Filter` at the end of the class name (which comes from the folder structure and namespacing constraints) was automatically detected. The vuejs component name only had one occurrence of `filter` in it.

This behavior changed in `0.8.0`:

* `Matestack::Ui::Core::Collection::Filter::Filter` will be translated to `matestack-ui-core-collection-filter-filter` without any further processing per default
* It is now possible to set the vuejs component name manually:

```ruby
class Matestack::Ui::Core::Collection::Filter::Filter < Matestack::Ui::DynamicComponent

  def vuejs_component_name
    "matestack-ui-core-collection-filter"
  end

  #...

end
```

**Migration Todos:**

(only for core developers)

-[ ] set vuejs component name explicitly in order to match current vuejs component names of all dynamic core components

*Custom components*

Custom components behaved differently than core components. `Components::Some::Component` was translated to a vuejs componente name `custom-some-component` in order to match their (now changed) dsl method name `custom_some_component`

This behavior changed in `0.8.0`:

* `Components::Some::Component` will be translated to `components-some-component` without any further processing per default
* It is now possible to set the vuejs component name manually:

```ruby
class Components::Some::Component < Matestack::Ui::DynamicComponent

  def vuejs_component_name
    "some-component"
  end

  #...

end
```

**Migration Todos:**

-[ ] set vuejs component name explicitly in order to match current vuejs component names of all custom components

OR

-[ ] adapt the name of your custom vuejs components to new naming schema

*AddOn engine components*

TODO

#### No more components block wrapping in Pages/Components/Apps

instead of:

```ruby
def response
  components {
    div do
      plain "hello!"
    end
  }
end
```

write now:

```ruby
def response
  div do
    plain "hello!"
  end
end
```

The `components` block is still supported but will be removed in a `1.0` release.

#### Partials are now normal method calls and don't need a block

instead of:

```ruby
def response
  components {
    div do
      partial :my_partial, "foo"
    end
  }
end

def my_partial param
  partial {
    plain param
  }
end
```

you can now write:

```ruby
def response
  div do
    my_partial "foo" #normal method call with optional params
  end
end

def my_partial param
  plain param # no more partial {} block
end
```

The old `partial` block and method call approach are still supported but will be removed in a `1.0` release.

#### Slot syntax stays the same

We still need the `slot` block wrapping around slot content

```ruby
def response
  div do
    some_static_component my_first_slot: my_simple_slot
  end
end

def my_simple_slot
  slot {
    span id: "my_simple_slot" do
      plain "some content"
    end
  }
end
```

### Components in Rails Views

It is now possible to use core and custom components in your Rails legacy views. Matestack provides a `matestack_component` helper to use components in views and partials.

Create a component
```ruby
class HeaderComponent < Matestack::Ui::StaticComponent
  requires :title

  def response
    header id: 'my-page-header' do
      plain title
    end
  end

end
```

Register it in your registry
```ruby
module Components::Registry
  Matestack::Ui::Core::Component::Registry.register_components(
    header_component: HeaderComponent,
  )
end
```

And use it in your view as follows:
```html
<%= matestack_component(:header_component, title: 'A Title') %>
```

### Rails Views in Matestack Pages/Components

To render existing rails views inside your components or pages use the new `rails_view` component. It replaces the old `html` component.
You can render existing partials and views with this helper anywhere in your app. 
Views/Partials that are rendered with a `rails_view` component can access instance variables of the corresponding controller 
or you can pass data directly as a hash to it and access it in your view. See below for further details and examples.

Rails View in a component:
```
```


### Removed Components

#### Inline Component

The Form Inline Component is removed and can no longer be used.

#### Absolute Component

The Absolute Component is removed and can no longer be used.


## v0.7.6

[Merged PRs](https://github.com/basemate/matestack-ui-core/pulls?q=is%3Apr+is%3Aclosed+milestone%3A0.7.6)

[Solved Issues](https://github.com/basemate/matestack-ui-core/issues?q=is%3Aissue+is%3Aclosed+milestone%3A0.7.6)

### Security Fixes

* Various dependency version bumps by dependabot

### Bugfixes

* Radio button groups with same values on single page #399
* Async rerendered components have access to ActionView context #405
* Transition component `active` class fixed #408 #410
* Query params were missing in async page load request when using browser history navigation #409

### Improvements

* Apps now have access to ActionView context #405
* Transition component `active-child` class added #410
* Added specs for ActionView context access #411
* Added file upload feature to form (single and multiple) #413
* Added form, transition, action `delay` option #412
* Added form, action `emit` option #412
* Added multi event listening to `async` component option #412 #147
* Added Rails 6 support
* Updated core dev and test environment to Rails 6
* Added form/action `redirect_to` option #415

## v0.7.5

[Merged PRs](https://github.com/basemate/matestack-ui-core/pulls?q=is%3Apr+is%3Aclosed+milestone%3A0.7.5)

[Solved Issues](https://github.com/basemate/matestack-ui-core/issues?q=is%3Aissue+is%3Aclosed+milestone%3A0.7.5)

### Security Fixes

* Various dependency version bumps by dependabot

### Improvements

* Added `datalist` component
* Added `range` type for `form_input`
* Integrated generator specs in CI spec run
* Added `turbolinks` support
* Form component: Add support for `redirect_to` in the controller
* HasViewContext: Check in advance whether the view context would respond to a missing method.

### Bugfixes

* Fixed broken history button behavior introduced in `0.7.4` #386

## v0.7.4

[Merged PRs](https://github.com/basemate/matestack-ui-core/pulls?q=is%3Apr+is%3Aclosed+milestone%3A0.7.4)

[Solved Issues](https://github.com/basemate/matestack-ui-core/issues?q=is%3Aissue+is%3Aclosed+milestone%3A0.7.4)

### Security Fixes

XSS/Script injection vulnerablilty fixed in 0.7.4

* matestack-ui-core was vulnerable to XSS/Script injection
* matestack-ui-core did not excape strings by default and did not cover this in the docs
* matestack-ui-core should have escaped strings by default in order to prevent XSS/Script injection vulnerability
* 0.7.4 fixes that by performing string escaping by default now
* a new component `unescaped` (like `plain` before) allows to render unsecaped strings, but forces the developer to explicitly make a concious decision about that

```ruby
class Pages::MyApp::MyExamplePage < Matestack::Ui::Page

  class FakeUser < Struct.new(:name)
  end

  def prepare
    @user = FakeUser.new("<script>alert('such hack many wow')</script>")
  end

  def response
    components {
      div do
        heading size: 1, text: "Hello #{@user.name}" # was not escaped , from 0.7.4 on it's escaped
        plain "Hello #{@user.name}" # was not escaped, from 0.7.4 on it's escaped
        unescaped "Hello #{@user.name}" # is not escaped, as intended
      end
    }
  end
end

```

Affected Versions

<= 0.7.3

Patched Versions

>= 0.7.4 --> please update!

Workarounds

escape string explicitly/manually

reported by @PragTob

### Improvements

* On form submit, matestack form values are reset to previous values by fiedl

--> The form component now does not reset itself when using `put`

--> The reset behavior can now be configured (described in `form` component docs)

* Dockerized core dev and test environment by jonasjabari

--> easy local dev and test setup, cross-platform default for dev and testing

--> CI is configured to run tests via dockerized test suite; same as local testing and good base for matrix testing (upcoming)

--> Usage described in contribution docs

* Add `follow_response` option to action component by fiedl

--> same behavior enhancement as added to the `form` component in 0.7.3

--> server may now decide where the transition should navigate to

--> described in `action` component docs

* Add confirm option to action component by fiedl

--> easily add confirmation before performing an action

--> prevent unintended delete action for example

--> described in `action` component docs

* New webpacker features by fiedl

  * make webpacker create es5 code instead of es6 code

  * Switch to Vue Production Mode if RAILS_ENV=staging or production

  * Establish webpack(er) and asset-pipeline workflows

--> webpacker now builds assets for asset pipline usage AND webpacker usage (both usage approaches are described in the installation docs)

--> webpacker now builds minified versions of matestack-ui-core.js (great improvement in file size!)

--> webpacker now builds es5 code, which is compatible with IE11

--> when used via asset pipeline, the minified version of matestack-ui-core together with the production build of vue.js is automatically required

--> when used via webpacker, matestack-ui-core can be used within a modern javascript workflow, importing and extending
single matestack module for example

* New components
  * Add HTML `<picture>` tag to core components by pascalwengerter
  * Add HTML `<option>` tag to core components by pascalwengerter
  * Add HTML `<optgroup>` tag to core components by pascalwengerter
  * Add HTML `<iframe>` tag to core components by pascalwengerter
  * Add HTML `<dfn>` tag to core components by pascalwengerter
  * Add HTML `<del>` tag to core components by pascalwengerter
  * Add HTML `<data>` tag to core components by pascalwengerter
  * Add HTML `<bdo>` tag to core components by pascalwengerter
  * Add HTML `<bdi>` tag to core components by pascalwengerter
  * Add HTML `<wbr>` tag to core components by pascalwengerter
  * Add HTML `<samp>` tag to core components by pascalwengerter
  * Add HTML `<u>` tag to core components by pascalwengerter
  * Add HTML `<template>` tag to core components by pascalwengerter


### Bugfixes

* Anchor Link Click triggers full page transition by PragTob


## v0.7.3

[Merged PRs](https://github.com/basemate/matestack-ui-core/pulls?q=is%3Apr+is%3Aclosed+milestone%3A0.7.3)

[Solved Issues](https://github.com/basemate/matestack-ui-core/issues?q=is%3Aissue+is%3Aclosed+milestone%3A0.7.3)

### Potential Breaking Change - Migration Note

Until `0.7.2.1`, we included all `ActionView` modules in `Matestack::Ui::StaticComponent` and `Matestack::Ui::DynamicComponent`. As we didn't use these modules in all of our core components, we decided to move the `ActionView` modules to the new `Matestack::Ui::StaticActionviewComponent` and `Matestack::Ui::DynamicActionviewComponent` class. If you use `ActionView` modules in your components, you have to change the class you inherit from. This might be a potential breaking change for some users - we are not bumping to 0.8.0 as we don't break explicit specified behavior. If you have any problems, reach out via gitter!

### Security Fixes

none

### Improvements

* Move ActionView dependencies to separate, custom-core-component by pascalwengerter
* Add documentation for testing on macOS by marcoroth
* Add HTML `<ruby>` tag to core components by stiwwelll
* Add HTML `<rt>` tag to core components by stiwwelll
* Add HTML `<rp>` tag to core components by stiwwelll
* Add HTML `<q>` tag to core components by GrantBarry
* Add HTML `<pre>` tag to core components by tae8838
* Add HTML `<param>` tag to core components by marcoroth
* Add HTML `<output>` tag to core components by marcoroth
* Add HTML `<object>` tag to core components by pascalwengerter
* Add HTML `<noscript>` tag to core components by stiwwelll
* Add HTML `<meter>` tag to core components by bdlb77
* Add HTML `<mark>` tag to core components by marcoroth
* Add HTML `<map>` tag to core components by pascalwengerter
* Add HTML `<legend>` tag to core components by stiwwelll
* Add HTML `<kbd>` tag to core components by marcoroth
* Add HTML `<ins>` tag to core components by lumisce
* Add HTML `<figure>` tag to core components by lumisce
* Add HTML `<em>` tag to core components by citizen428
* Add HTML `<dt>` tag to core components by mayanktap
* Add HTML `<dl>` tag to core components by mayanktap
* Add HTML `<dd>` tag to core components by mayanktap
* Add HTML `<code>` tag to core components by pascalwengerter
* Add HTML `<cite>` tag to core components by cameronnorman
* Add HTML `<var>` tag to core components by pascalwengerter
* Add HTML `<s>` tag to core components by Manukam
* Add HTML `<bold>` tag to core components by GrantBarry
* Add HTML `<area>` tag to core components by pascalwengerter
* Add tests for video component by MarcoBomfim
* Usage of RecordTagHelper by pascalwengerter
* Add HTML `<aside>` tag to core components by borref
* Add HTML `<address>` tag to core components by michaelrevans
* Add HTML `<sup>` tag to core components by borref
* Add params options to link component documentation by pascalwengerter

### Bugfixes

* Unexpected behavior when creating a record in progress by jonasjabari
* couldn't find file 'matestack_ui_core_manifest.js' on dummy app by jonasjabari
* Add For Attribute to Stand Alone Label Component by bdlb77
* Form component doesn't work on component-level by jonasjabari
* Async component doesn't work on component-level by jonasjabari


## v0.7.2.1

[Merged PRs](https://github.com/basemate/matestack-ui-core/milestone/5?closed=1)

### Security Fixes

- Dependency version bump (nokogiri) by dependabot

### Bugfixes

- Fixed image component 157 #158 by jonasjabari

## v0.7.2

[Merged PRs](https://github.com/basemate/matestack-ui-core/milestone/4?closed=1)

### Security Fixes

- Various dependency version bumps by dependabot

### Improvements

- Add Isolation Component #154 by jonasjabari
- Update integration docs #149 by pascalwengerter
- Add youtube component #144 by pascalwengerter
- Support new Doc App #143 by jonasjabari
- Add class option to dropdown form selects  enhancement#135 by 3wille
- Refactor core components v2  enhancement#134 by pascalwengerter
- add sub tag  enhancement#132 by pascalwengerter
- Add article component with docs and specs #127 by michaelrevans
- Add address tag, specs and documentation #126 by michaelrevans
- Extra table components #125 by michaelrevans
- Add abbr component with specs and documentation #124 by michaelrevans
- Add article component with docs and specs #122 by michaelrevans
- Add address tag, specs and documentation #121 by michaelrevans
- Add abbr component #120 by michaelrevans
- Add thead, tbody and tfoot components

### Bugfixes

- Add init_show state to async component 140 #152 by jonasjabari
- added missing @tag_attributes #151 by jonasjabari
- update yarn and fix controller action name #141 by pascalwengerter

## v0.7.1

[Merged PRs](https://github.com/basemate/matestack-ui-core/milestone/3?closed=1)

### Improvements

- Introduce scaffolder #72 by PasWen
- Make buttons disableable  enhancement by PasWen
- Collection Component #98 by jonasjabari
- Added Async Defer Feature #100 by jonasjabari
- Added blockquote tag to main component #88 by cameronnorman
- Added small tags #87 by cameronnorman
- Added strong tag #93 by cameronnorman
- Added Infos that async component can currently only be used on page leve #85 by jonasjabari was merged 10
- Update span component in 0.7.0 #74 by PasWen
- Add documented, untested video component #70 by PasWen
- Added summary details components #76 by bdlb77
- Add caption with doc and specs  enhancement #68 by michaelrevans

### Bugfixes

- Fixed Link Component #84 by jonasjabari

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
