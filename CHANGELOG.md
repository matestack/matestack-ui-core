# Changelog

## v2.1.0 Release - 2021-06-28

### Improvements

- Nested Form Support #558
- Component render? Method #553
- Page Component Cleanup
- Docs Cleanup

### Bugfixes


## v2.0.0 Release - 2021-04-12

Please refer to the [migration guide](./docs/migrate-from-1.x-to-2.0.md)

## v1.5.0 Release - 2021-03-07

### Improvements

- NPM package usage

## v1.4.0 Release - 2021-02-05

### Improvements

- Ruby 3 support
- Vue update to 2.6.12
- Vuex update to 3.6.2
- Gemspec update clarifying that Rails below 5.2 is not supported (EOL versions anyway!)
- CI test runs against multiple Rails/Ruby version combination

### Bugfixes

- Webpacker 6 support #500

### Security bumps

- Various version bumps triggered through dependabot

## v1.3.2 Release - 2021-01-11

### Bugfixes

- Fixes #503 new vue-turbolinks v2.2.0 causes error on webpacker compile

### Security bumps

- Various version bumps triggered through dependabot

## v1.3.1 Release - 2020-12-28

### Bugfixes

- Fixes #497 Cable component throws browser error when initial content contains form component

## v1.3.0 Release - 2020-12-22

### Potential breaking change

If you have used a `form_submit` component like this:

```ruby
form_submit do
  button text: "Submit me!", attributes: { "v-bind:disabled": "loading" }
end
```

in order to disable the the button during submission of the form, please turn `loading` into `loading()`:


```ruby
form_submit do
  button text: "Submit me!", attributes: { "v-bind:disabled": "loading()" }
end
```

If you have implemented your own form components, please adjust them as described in the customize section of each form component. Most likely, you now have to provide exactly one root element per form component due to the reworked form components.

### Improvements

- Splitted form API docs into multiple files
- Implements #474 Add HTML `<select>` tag to core components
- Implements #492 Enable extendability of `form_*` components
  - Reworked `form_*` components in order to provide a better API for custom form components
  - `form_*` components are separate Vue.js components now
  - Each `form_*` uses a Vue.js mixin and a Ruby base class. This mixin and base class can be used in custom components in order to easy create own form components

## Bugfixes

- Fixes #490 Custom classes for checkboxes
- Fixes #494 true/false checkboxes are initialized incorrectly


## v1.2.0 Release - 2020-11-20

### Improvements

* Enable usage of Rails view/route helpers on standalone components used via matestack_component helper #476

## v1.1.0 Release - 2020-10-16

### Improvements

* added the `cable` component in order to use ActionCable to update the DOM

## v1.0.1 Release - 2020-10-07

This release contains bugfixes.

### Bugfixes

*  Fixed javascript automatic scroll top on page transition for short pages #462
*  Enable async components on app level, only usable in pages and components before #458
*  Fixed duplicate directory error when using matestack-ui-core with webpacker #460


## v1.0.0 Release - 2020-09-10

Please note that this release contains breaking changes and soft deprecations. To make things easy for users of the current `v0.7.*` version, we have provided **Migration TODOs** at the end of each chapter.

### Migration guide for 0.7.x users

#### 1. Using `render Pages::X` instead of `responder_for(Pages::X)` in controllers

Instead of:

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

Please note that while the `responder_for` method is still being supported, it will be removed in a future release.

**Migration TODOs:**

- [ ] Replace `responder_for` with `render` in your controllers

#### 2. App/Page structure and namespacing

Until `0.7.x`, matestack-ui-core enforced the user to keep apps and pages in a specific folder structure. An app like `Apps::MyApp` had to be stored in `app/matestack/apps/my_app.rb` and an associated page like `Pages::MyApp::MyPage` lived in `app/matestack/pages/my_app/my_page.rb`. The namespace `Pages::MyApp` determined that the page `MyPage` should be wrapped with the layout coming from `Apps::MyApp`.

We changed this behavior in favor of more intuitive namespacing and more control/flexibility on namespaces and folder structure:

**Flexible folder structure and namespacing of apps and pages**

Apps and pages can now actually live anywhere within your project - but we still recommend sticking to some best practices, shown further below. The relation between apps and pages is no longer derived from the (folder) namespace.

**Explicit app/page relation on controller level**

Within a controller, you can now set the desired `matestack_app` that then wraps all pages used in this controller. This definition is inheritable - therefore, you can set in on an `ApplicationController` to make it a default for all controllers and actions, and overwrite it if needed.

Both "global" and "controller-level" `matestack_app` settings can be overwritten on "action-level" using an additional parameter for the `render` method.

The code snippet below shows some common use cases:

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
If no `matestack_app` is defined or it is deliberately set to `:none` as demonstrated above, matestack-ui-core will by default render the page wrapped by a minimal app. This happens in order to provide basic app-related matestack-ui-core features like `transition` and others.

It is possible to explicitly prevent this behavior by setting `matestack_app` to false:

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

Imagine your project has two "apps". An "admin" area and a public "website" area. Your folder structure could look like this:

```
app/matestack/
|
└───admin/
│   │   app.rb (`Admin::App < Matestack::Ui::App`)
│   └───pages/
│   │   │   dashboard.rb  (`Admin::Pages::Dashboard < Matestack::Ui::Page`)
|
└───website/
│   │   app.rb (`Website::App < Matestack::Ui::App`)
│   └───pages/
│   │   │   home.rb  (`Website::Pages::Home < Matestack::Ui::Page`)
```

and your corresponding controllers could look like this:

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

You can decide to either
- [ ] keep the `0.7.x` folder structure if you want
- [ ] and set the related app on your controllers via `matestack_app` (as it will no longer be derived automatically from the page namespace)

or

- [ ] refactor your app/page structure according to your needs, and set the related apps on a controller level

#### 3. Base component class name adjustments

We decided to rename the base component class names in order to create a better understanding of what they are:

* `Matestack::Ui::StaticComponent` --> `Matestack::Ui::Component`
* `Matestack::Ui::DynamicComponent` --> `Matestack::Ui::VueJsComponent`

**Migration TODOs:**

You can decide to either
- [ ] we still keep the old class names, but we recommend to adjust the base class names as described above

#### 3. Explicit component registration

A major change happened to the component resolving approach. Until `0.7.x`, matestack-ui-core automatically translated core component calls like `some_component` to a class like `Matestack::Ui::Core::Some::Component`, which had to be defined within the core library at `CORE_ROOT/app/concepts/matestack/ui/core/some/component.rb`. The same applied for custom component calls like `custom_my_component` which resolved to a class `Components::My::Component` which had to be defined within the user's application at `APP_ROOT/app/matestack/components/my/component.rb`.

This auto resolving is being completely removed in the `1.0.0` release. All components (core, custom and add-on-engine) have to be registered explicitly as described below:

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

Like in the core, the registered DSL method `my_component` does not have to match the component's namespace structure. In this example, the custom `MyOwnComponent` lives in `app/matestack/components/my_own_component.rb` and is being referenced as `my_component`.

TBD:

Please be aware that once the component registry was loaded, the initially registered dsl_methods are cached. Removing a dsl_method from the registry will not have an effect until the server gets reloaded. Added dsl_methods however will be available without having to restart the server.

*AddOn engine component*

TODO

**Migration TODOs:**

If you are already using custom components:
- [ ] Add a component registry in `APP_ROOT/app/matestack/components/registry.rb`
- [ ] Register your existing components like `    my_component: Components::MyOwnComponent`, respecting their namespaces and setting dls_methods of your choice. The obligation of prefixing them with a `custom_` does no longer apply.
- [ ] Since the new dls_methods may differ from the former method calls, you need to refactor the custom component usage on existing apps and pages (e.g. formerly `custom_my_own_component` should now be called `my_component`)

#### 4.1 Dynamic (Vue.js) core component naming

Until `1.0.0`, dynamic core components created the Vue.js component name automatically by deriving it from their class name. `Matestack::Ui::Core::Collection::Filter::Filter`, for example, was translated to the Vue.js componente name `matestack-ui-core-collection-filter`. The two occurrences of `Filter` at the end of the class name (which comes from the folder structure and namespacing constraints) was automatically detected and taken care of, so the Vue.js component name only had one occurrence of `filter` in it.

This behavior changes in `1.0.0`:

* `Matestack::Ui::Core::Collection::Filter::Filter` will be translated to `matestack-ui-core-collection-filter-filter` without any further processing per default
* It is now possible to set the Vue.js component name manually within the component configuration:

```ruby
class Matestack::Ui::Core::Collection::Filter::Filter < Matestack::Ui::VueJsComponent
  vue_js_component_name "matestack-ui-core-collection-filter"

  #...

end
```

**Migration Todos:**

Core developers only:
-[ ] set Vue.js component name explicitly in order to match current Vue.js component names of all dynamic core components

#### 4.2 Dynamic (Vue.js) custom component naming

Formerly, custom components behaved differently than core components. `Components::Some::Component` was translated to a Vue.js component named `custom-some-component`, in order to match their (now changed) dsl method name `custom_some_component`

This behavior changes in `1.0.0`:

* Without any further default processing, `Components::Some::Component` will be translated into `components-some-component`
* It is now possible to set the Vue.js component name manually:

```ruby
class Components::Some::Component < Matestack::Ui::VueJsComponent
  vue_js_component_name "some-component"

  #...

end
```

**Migration Todos:**

Please note that you have two options, but an action is required to make the new release work with existing custom dynamic components. Either you

- [ ] set Vue.js component name explicitly in order to match current Vue.js component naming of all custom components

OR

- [ ] adapt the name of your custom Vue.js components to the new naming schema demonstrated above


#### 5. No more components block wrapping in Pages/Components/Apps

Instead of:

```ruby
def response
  components {
    div do
      plain "hello!"
    end
  }
end
```

you can now write:

```ruby
def response
  div do
    plain "hello!"
  end
end
```

Please note that the `components` block is still supported, but will be removed in a `1.0` release.

**Migration Todos:**

- [ ] To be on the safe side, remove all the `components {}` wrapping blocks in your apps and pages


#### 6. Partials are now normal method calls and don't need a block

Instead of writing:

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

Please note that the old `partial` block and method call approach are still supported but will be removed in a `1.0` release.

**Migration Todos:**

- [ ] To be on the safe side, remove all the `partial {}` wrapping blocks in the partials on your apps, pages and custom components

#### 7. Slot syntax stays the same

We still need the `slot` block wrapping around slot content

```ruby
def response
  div do
    some_static_component my_first_slot: my_simple_slot
  end
end

def my_simple_slot
  slot do
    span id: "my_simple_slot" do
      plain "some content"
    end
  end
end
```

#### 8. `page_content` should now be `yield_page`

We changed the naming to be more expressive and in order to align with the existing `yield_components`

**Migration Todos:**

- [ ] On an app layout, you should now use `yield_page` instead of `page_component`

#### 9. Wrapping DOM structure of pages has changed

We changed the DOM structure around pages in order to enable better page loading state implementations.
We also changed the class names of these wrapping divs in order to better match css naming conventions

```html
<!-- some layout markup -->
<div class="matestack-page-container">
  <div class="matestack-page-wrapper">
    <div><!--this div is necessary for conditional switch to async template via v-if -->
      <div class="matestack-page-root">
        your page markup
      </div>
    </div>
  </div>
</div>
<!-- some layout markup -->
```

**Migration Todos:**

- [ ] If you used the old DOM structure and css class names of the wrapping elements for styling, please adjust your CSS accordingly

#### 10. `yield_page` can now take a loading_state slot

In order to simplify the implementation of page loading state effects, we added an optional loading_state slot for `yield_page`:

`app/matestack/example_app/app.rb`

```ruby
class ExampleApp::App < Matestack::Ui::App

  def response
    # some layout stuff
    main do
      yield_page slots: { loading_state: my_loading_state_slot }
    end
    # some layout stuff
  end

  def my_loading_state_slot
    slot do
      span class: "some-loading-spinner" do
        plain "loading..."
      end
    end
  end

end
```

which will render:

```html
<main>
  <div class="matestack-page-container">
    <div class="loading-state-element-wrapper">
      <span class="some-loading-spinner">
        loading...
      </span>
    </div>
    <div class="matestack-page-wrapper">
      <div><!--this div is necessary for conditional switch to async template via v-if -->
        <div class="matestack-page-root">
          your page markup
        </div>
      </div>
    </div>
  </div>
</end>
```

and during async page request triggered via transition:

```html
<main>
  <div class="matestack-page-container loading">
    <div class="loading-state-element-wrapper loading">
      <span class="some-loading-spinner">
        loading...
      </span>
    </div>
    <div class="matestack-page-wrapper loading">
      <div><!--this div is necessary for conditional switch to async template via v-if -->
        <div class="matestack-page-root">
          your page markup
        </div>
      </div>
    </div>
  </div>
</end>
```

You can use the `loading` class and your loading state element to implement CSS based loading state effects.

#### 11. `async` component now requires an ID

We changed the way how matestack resolves the content of an `async` component on rerender calls. It is now required to apply an ID to the `async` component

```ruby
async rerender_on: "some-event", id: "my-unique-id" do
  plain hello!
end
```

**Migration Todos:**

- [ ] Please add an unique ID to each `async` component usage, even if matestack is currently auto-generating an ID if not applied. This will be removed in future releases

#### 12. New `toggle` component is replacing `async` shown_on, hide_on, hide_after...

We decided to move all pure clientside view state manipulation logic from the `async` component to a new component called `toggle`. `async` should now only take care of serverside rerendering based on events.

```ruby
async show_on: "some-event" do
  plain hello!
end
# should now be:
toggel show_on: "some-event" do
  plain hello!
end
```

**Migration Todos:**

- [ ] Please use the new `toggle` component wherever you used `async show_on/hide_on/hide_after`

#### 13. `async` DOM structure and loading state

The `async` components wrapping DOM structure has changed in order to align with the wrapping DOM structure of pages and isolated components:

```ruby
async rerender_on: "some-event", id: "my-unique-id" do
  plain hello!
end
```

will render to:

```html
<div class="matestack-async-component-container">
  <div class="matestack-async-component-wrapper">
    <div id="my-unique-id" class="matestack-async-component-root">
      hello!
    </div>
  </div>
</div>
```

and during rerender:

```html
<div class="matestack-async-component-container loading">
  <div class="matestack-async-component-wrapper loading">
    <div id="my-unique-id" class="matestack-async-component-root" >
      hello!
    </div>
  </div>
</div>
```

**Migration Todos:**

- [ ] If you used the old DOM structure and css class names of the wrapping elements for styling, please adjust your CSS accordingly


#### 14. `form` component changes

We reworked the form components quite a bit:

- `include` keyword is no longer required
- `form_input` component no longer supports the input type textarea.
- Textareas were extracted in a component and can be used as standalone`textarea` or in forms with `form_textarea`.
- `form_input`component now supports all types according to W3Cs possible types.
- `form_select` is now only used for HTML select dropdowns
- `form_radio` is used for rendering radio button inputs
- `form_checkbox` is used for rendering checkbox inputs, either a single (true/false) checkbox or multiple checkboxes
- options passed as hashes in to `form_select`, `form_radio` and `form_checkbox` are now expected to be { label_value: input_value } and thus the other way around. Until 0.7.6 it was { input_value: label_value }
- and added a lot of new features, such as customizing the error rendering.

We invested a lot of time to improve the `form` API docs found [here](/docs/api/100-components/form.md).

- [ ] Please make sure to read through the docs and migrate your forms accordingly!

#### 15. New approach towards isolated components

We completely rethought the way we approached isolated components.

The old approach:

```ruby
def response
  #...
  isolate :my_isolated_scope
  #...
end

def my_isolated_scope
  isolate {
    plain "I'm isolated"
  }
end
```
is removed.

Instead, we created a new component class `Matestack::Ui::IsolatedComponent`. You can build custom component which inherits from this class in order to create components, which will be resolved completely isolated on rerender calls:

```ruby
class MyPage < Matestack::Ui::Page

  def response
    #...
    my_isolated_component defer: true, public_params: { id: 1 }
    #...
  end

end
```

```ruby
class MyIsolatedComponent < Matestack::Ui::IsolatedComponent

  def prepare
    my_model = MyModel.find public_params[:id]
  end

  def response
    div do
      plain "#{my_model} was resolved isolated within in a separate http request after page load"
    end
  end

  def authorized?
    true
    # check access here using current_user for example when using Devise
    # true means, this isolated component is public
  end
end
```

Using an isolated component with `defer` speeds up the init page load on complex UIs.

**Migration Todos:**

- [ ] Create custom isolated components wherever you used the old approach towards isolate

#### 16. Params access from apps, pages and components

In order to access to request params like we do on controller level, we added the `params` method to apps, pages and components:

```ruby
def response
  plain context[:params][:id]
  #or
  plain @url_params[:id]
end

# should now be:
def response
  plain params[:id]
end
```

**Migration Todos:**

- [ ] Switch to the new `params` method in order to access request params. `@url_params` will be deprecated in future releases

#### 16. LICENSE change

As we're performing a major release from 0.7.6 to 1.0.0, we're able to switch the license. We decided to go for the [LGPLv3 license](http://www.gnu.org/licenses/lgpl-3.0.html) following the example of Sidekiq or Trailblazer. That won't have an effect on users of our library as long as you're just using `matestack-ui-core` and not creating/publishing a derivative work. You can use `matestack-ui-core` in commercial closed source applications without any issues.Trailblazer has a comprehensive article on that [topic](https://trailblazer.to/2.1/docs/pro.html#pro-license).

Our goal is to create a sustainable open source project. Therefore we need to secure funding. Selling commercial licenses on top of the LGPLv3 license for companies wanting to create/sell closed source derivative work of `matestack-ui-core` should be one pillar of that funding.

#### 17. Wrap-up

After following all the **Migration Todos**, your application should work just fine. If that's not the case, please [open a GitHub issue](https://github.com/matestack/matestack-ui-core/issues/new) and/or improve this guide!

### Improvements

#### Using matestack components in Rails Views

It is now possible to use `matestack-ui-core` core and custom components in your Rails legacy views. Matestack provides a `matestack_component` helper to use components in views and partials.

Create a custom component like
```ruby
class HeaderComponent < Matestack::Ui::Component
  requires :title

  def response
    header id: 'my-page-header', text: title
  end

end
```

and register it in your registry
```ruby
module Components::Registry
  Matestack::Ui::Core::Component::Registry.register_components(
    header_component: HeaderComponent,
  )
end
```

Now, you can go ahead and use it in your views as shown below, even passing arguments works:
```html
<%= matestack_component(:header_component, title: 'A Title') %>
```

### Using Rails Views in Matestack Pages/Components

To render existing rails views inside your components or pages, use the new `rails_view` component. It replaces the old `html` component.
You can render existing partials and views with this helper anywhere in your app. For further information read the `rails_view` documentation.

Let's say you have an old view file in `app/views/example/partial.html.erb`

```html
<p>An example text in a Rails view</p>
```

You could go ahead and re-use it in a component (or simply add it to a page) like:
```ruby
class TextComponent < Matestack::Ui::Component

  def response
    paragraph text: 'Example text directly in the component'
    rails_view path: `example/partial.html.erb`
  end

end
```

### Collection select



### Removed Components

#### 1. Inline Component

The Form Inline Component has been removed and can no longer be used.

#### 2. Absolute Component

The Absolute Component has been removed and can no longer be used.

## v0.7.6 - 2020-05-06

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

## v0.7.5 - 2020-03-11

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

## v0.7.4 2020-02-10

[Merged PRs](https://github.com/basemate/matestack-ui-core/pulls?q=is%3Apr+is%3Aclosed+milestone%3A0.7.4)

[Solved Issues](https://github.com/basemate/matestack-ui-core/issues?q=is%3Aissue+is%3Aclosed+milestone%3A0.7.4)

### Security Fixes

XSS/Script injection vulnerablilty fixed in 0.7.4

* matestack-ui-core was vulnerable to XSS/Script injection
* matestack-ui-core did not escape strings by default and did not cover this in the docs
* matestack-ui-core should have escaped strings by default in order to prevent XSS/Script injection vulnerability
* 0.7.4 fixes that by performing string escaping by default now
* a new component `unescaped` (like `plain` before) allows to render unescaped strings, but forces the developer to explicitly make a concious decision about that

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


## v0.7.3 - 2019-11-10

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


## v0.7.2.1 - 2019-09-10

[Merged PRs](https://github.com/basemate/matestack-ui-core/milestone/5?closed=1)

### Security Fixes

- Dependency version bump (nokogiri) by dependabot

### Bugfixes

- Fixed image component 157 #158 by jonasjabari

## v0.7.2 - 2019-09-05

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

## v0.7.1 - 2019-08-01

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

## v0.7.0 - 2019-06-25

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

## v0.6.0 - 2019-04-27

### Improvements

* added documentation
* added tests

## v0.6.0.pre.1 - 2019-02-26

This release is marked as PRE. Test coverage is not sufficient at the moment.

### Breaking Changes

* Form component now need the ':include' keyword in order to populate the form config to its children
* Input components are now renamed to form_* in order to show their dependency to a parent form component

### Improvements

* partials may now be defined in modules and used across multiple page classes
* components may now define required attributes, which get validated automatically
* components now raises more specific error messages
