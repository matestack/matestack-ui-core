# rails\_view

Use your Rails views or partials with this component in your views, matestack pages, components or apps.

## Parameters

This component expects that either `view` or `partial` is given as parameter.

### view \(optional\)

Expects a string, specifying the path of the view that should be rendered by the component. The path resolution works like Rails `render 'your_path'` path resolution.

### partial \(optional\)

Expects a string, specifying the partial that should be rendered by the component. The path resolution works like Rails `render partial: 'your_path'` path resolution.

## Example 1 - Using Rails View and Partial on a page, component or app

```ruby
class WelcomePage < Matestack::Ui::Page
  def response
    rails_view view: 'welcome/header'
    rails_view partial: 'welcome/hero'
    heading text: 'Welcome', size: 1
  end
end
```

The above page will first render your 'welcome/header' view. If for example you use erb templates, it will render your `app/views/welcome/header.html.erb` view. And secondly it will render your 'welcome/hero' partial. Again, if you use erb templates, it will render your `app/views/welcome/_hero.html.erb` partial. The usage of `rails_view` is the same on a page, component or app.

## Example 2 - Using Rails View in a view

You can also use `rails_view` in another view

```markup
<%= matestack_component(:rails_view, view: 'welcome/header') %>
<%= matestack_component(:rails_view, partial: 'welcome/hero') %>
```

## Example 3 - Passing and accessing data

You can access all your instance variables from your controller action within a view or partial rendered by `rails_view`. You can also pass data explicitly. Just add them to the hash you pass to the `rails_view` call. You can access those like you would do if you pass `locals` to a rails view or partial.

Your `rails_view` call:

```ruby
rails_view view: 'welcome/header', headline: 'Great to see you!'
```

and in your rails view you can access your data as follows:

```text
<h1><%= headline %></h1>
```

