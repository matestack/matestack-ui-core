# matestack core component: Hr

Show [specs](/spec/usage/components/hr_spec.rb)

The HTML `<u>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params.

#### # id (optional)
Expects a string with all ids the u should have.

#### # class (optional)
Expects a string with all classes the u should have.

## Example 1
Adding an optional id

```ruby
div id: "foo", class: "bar" do
  u id: "u-id"
end
```

returns

```html
<div id="foo" class="bar">
  <u id="u-id">
</div>
```

## Example 2
Adding an optional class

```ruby
div id: "foo", class: "bar" do
  u class: "u-class"
end
```

returns

```html
<div id="foo" class="bar">
  <u class="u-class">
</div>
```
