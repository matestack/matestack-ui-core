# Basic Building Blocks

matestack's UI concept consists of three major building blocks: "component", "page" and "app".
A component is a reusable UI-Element. A page contains multiple components
and represents the main content on a specific view. Multiple
pages can be wrapped in an app, sharing a layout for example.

## Component

If you think of an UI, a small component may be a simple button. A bigger component may
use three other components, including an image-component, a text-component and this
button-component to display a product-image, -description and a "more details" button.

A component is the smallest UI-Element and can consist of other components. matestack
provides a wide set of core components, which enables you to easily build your UI.
You can build your own components as well, either static or dynamic.

Learn more about [components](component.md)

Show all core [components](../components/README.md)

## Page

20 of these product-components should be displayed on a specific page of your Web-App.
A page therefore defines, that 20 product-components should be used and how they should
be aligned to each other.

A page composes multiple components in order to display the main content.

Learn more about [pages](page.md)

## App

Usually a page should be wrapped in a layout. A layout may define a navigation-menu,
header and footer for example. In matestack, a layout is defined in an app. Multiple
pages belong to one matestack app, which can perform dynamic transitions
between its pages. A Rails Application may host multiple matestack apps: One could
be the Online-Shop-App, displaying products on multiple pages. The other could be
an Backoffice-App managing all kind of data and processes.

A matestack app manages multiple pages in order to fullfill one specific purpose of your organization.

Learn more about [apps](app.md)
