---
description: Still WIP --> 3.0 and future 3.1 changes needs to be added here
---

# Integrating Action View Helpers

Using Rails view helpers ([https://api.rubyonrails.org/classes/ActionView/Helpers.html](https://api.rubyonrails.org/classes/ActionView/Helpers.html)) in components, pages and apps is supported with some limitations currently.&#x20;

## Helpers without a block

You just have to put a `plain` before a view helper, if this view helper is rendering a HTML string, for example:

```ruby
plain link_to "Show", post_path(@post)
```

{% hint style="info" %}
A component needs to be called in context of a controller (with included `Matestack::Ui::Core::Helper`), which is true when you're calling components from Rails views or on Matestack Pages/Layouts (which are themselves called by a controller normally).

When calling a component in isolation (which is possible), the view helpers might not work properly!
{% endhint %}

## Helpers yielding a block

{% hint style="danger" %}
It's currently not possible to use view helpers requiring a block, such as the `form_for`. We're working on supporting them soon!
{% endhint %}

If you want to use a helper like `form_for` please bypass the current limitation by integrating a Rails partials as describe in the next section.
