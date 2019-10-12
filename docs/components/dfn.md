# matestack core component: Hr

Show [specs](/spec/usage/components/dfn_spec.rb)

The HTML `<dfn>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params.

#### # id (optional)
Expects a string with all ids the dfn should have.

#### # class (optional)
Expects a string with all classes the dfn should have.

## Example 1
Adding an optional id

```ruby
div id: "foo", class: "bar" do
  dfn id: "dfn-id"
end
```

returns

```html
<div id="foo" class="bar">
  <dfn id="dfn-id">
</div>
```

## Example 2
Adding an optional class

```ruby
div id: "foo", class: "bar" do
  dfn class: "dfn-class"
end
```

returns

```html
<div id="foo" class="bar">
  <dfn class="dfn-class">
</div>
```
