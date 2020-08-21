# Base API

matestack's UI concept consists of three major building blocks: `component`, `page` and `app`.
A component is a reusable UI-Element. A `page` contains multiple `components`
and represents the main content on a specific view. Multiple
`pages` can be wrapped in an `app`, sharing a layout for example.

If you think of an UI, a small `component` may be a simple button. A bigger `component` may
use three other components, including an image-component, a text-component and this
button-component to display a product-image, -description and a "more details" button.

A `component` is the smallest UI-Element and can consist of other components. matestack
provides a wide set of core components, which enables you to easily build your UI.
You can build your own components as well!

20 of these product-components should be displayed on a specific `page` of your Web-App.
A `page` therefore defines, that 20 product-components should be used and how they should
be aligned to each other.

A `page` composes multiple components in order to display the main content.

Usually a `page` should be wrapped in a layout. A layout may define a navigation-menu,
header and footer for example. In matestack, a layout is defined in an `app`. Multiple
`pages` belong to one matestack `app`, which can perform dynamic transitions
between its `pages`. A Rails application may host multiple matestack `apps`: One could
be the Online-Shop-App, displaying products on multiple `pages`. The other could be
an Backoffice-App managing all kind of data and processes.

A matestack `app` manages multiple `pages` in order to fullfill one specific purpose of your organization.

## Components

### Types of components

Matestack uses three different types of components:

* Component
* VueJsComponent
* IsolatedComponent

All components define their UI within a `response` method, written in Ruby.

#### Component

The simplest type of a component inherits from `Matestack::Ui::Component` and is
meant to be used for simple rendering of content and other components. Matestack
will simply render the UI defined within the `response` method without any
wrapping elements by default.

[Read more](/docs/api/base/component.md)

#### VueJsComponent

In order to equip a Ruby component with some JavaScript, we associate
the Ruby component with a VueJs JavaScript component. The Ruby component therefore needs to inherit
from `Matestack::Ui::VueJsComponent`. Matestack will then render a HTML component
tag with some special attributes and props around the response defined in the
Ruby component. The VueJs JavaScript component (defined in a separate JavaScript file and
managed via Sprockets or Webpacker) will treat the response of the Ruby
component as its template.

[Read more](/docs/api/base/vue_js_component.md)

#### IsolatedComponent

Components inheriting from `Matestack::Ui::IsolatedComponent` are designed for
isolated, asynchronous rendering. Like seen at VueJsComponents, Matestack will
render a HTML component tag with some special attributes and props around the
response defined in the Ruby component. Additionally, Matestack wraps the
component's `response` with some DOM elements enabling asynchronous loading
state animations.

[Read more](/docs/api/base/isolated_component.md)

### Core Components

Matestack ships a lot of core components. A lot of them are simple `Matestack::Ui::Component`s
and representing HTML tags in order to enable the developer to create html markup
with pure Ruby. Some other core components are `Matestack::Ui::VueJsComponent`s shipping
predefined dynamic UI behavior.

See [here](/docs/api/components/core/README.md) for a list of available `core components`.

### Custom Components

By definition, custom components only live within your application.
To use them on your `apps` and `pages`, you need to register them in a component
registry file. Custom components can inherit from `Matestack::Ui::Component`,
`Matestack::Ui::VueJsComponent` or `Matestack::Ui::IsolatedComponent` depending on
the specific usecase.

[Read more](/docs/api/components/custom/README.md)

## Pages

A page orchestrates components within its response method. A Rails controller
action references a page (and its corresponding app) in its render call. Thus a
matestack page substitutes a typical Rails view.

A page is a special kind of `Matestack::Ui::VueJsComponent`. Matestack will
therefore wrap the UI defined in the `response` method with some markup enabling
dynamic UI behavior and CSS styling.

Learn more about [pages](/docs/api/base/page.md)

## Apps

An app defines a layout within its `response` method and uses the `yield_page`
method to yield the content of a page in its layout.

An app is a special kind of `Matestack::Ui::VueJsComponent`. Matestack will
therefore wrap the UI defined in the `response` method with some markup enabling
dynamic UI behavior and CSS styling.

The app ships a `Vuex store` and `Vue.js event hub`, which are used by core vuejs
components and can optionally be used by custom vuejs components in order to
trigger events, manage client side date and communicate between components.

Learn more about [apps](/docs/api/base/app.md)
