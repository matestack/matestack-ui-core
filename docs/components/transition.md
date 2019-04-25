# basemate core component: Transition

This component is used to perform animations between page transitions. It renders a `<a>` tag around text or optional content and changes the UI based on its specifications.

## Parameters
The basemate transition expects at least a link\_path. Depending on what you want to achieve, it can take further params.

#### # link\_path
Specifies where the `<a>` should link to. Gets rendered into a "href".

If the path input is a **string** it creates a link to that route (e.g. `link_path: "about"` -> basemate.io/about).

If the path input is a **symbol** (e.g. :root_path) it creates a route **within** your Rails application.

#### # id (optional)
Expects a string with all ids the `<a>` tag should have.

#### # class (optional)
Expects a string with all classes the `<a>` tag should have.

#### # text (optional)
Expects a string with the text that should go into the `<a>` tag.


"v-bind:class": "{ active: isActive }"}


## Options

The transition component becomes **'active'** if the current route matches the destination route. You can use this to apply styles to your view.

In your application.js, you can define custom

* basemateUiCoreTransitionStart
* basemateUiCoreTransitionSuccess
* basemateUiCoreTransitionError

functions to create - for example - alert and notice messages.

See a working example of this in action
[here](https://basemate.io/guides/add_ui_sugar).
