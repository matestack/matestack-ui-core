# matestack core component: Icon

Show [specs](../../spec/usage/components/icon_spec.rb)

The HTML `<i>` tag implemented in ruby. Use it for fancy icons!

## Parameters

This component can take 3 optional configuration params.

#### # id (optional)
Expects a string with all ids the icon should have.

#### # class (optional)
Expects a string with all classes the icon should have.

#### # class (optional)
Expects a string with all the content the icon should have.

## Example 1
Rendering a Font Awesome icon

```ruby
icon id: "foo", class: "fa fa-car"
```

returns

```html
<i id="foo" class="fa fa-car"></i>
```

## Example 2
Rendering a Material Design icon

```ruby
icon id: "foo", class: "material-icons", text: "accessibility"
```

returns

```html
<i id="foo" class="material-icons">accessibility</i>
```
