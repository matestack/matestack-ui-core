# matestack core component: Hr

Show [specs](/spec/usage/components/hr_spec.rb)

The HTML `<hr>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params.

#### # id (optional)
Expects a string with all ids the hr should have.

#### # class (optional)
Expects a string with all classes the hr should have.

## Example 1
Adding an optional id

```ruby
div id: "foo", class: "bar" do
  hr id: "hr-id"
end
```

returns

```html
<div id="foo" class="bar">
  <hr id="hr-id">
</div>
```

## Example 2
Adding an optional class

```ruby
div id: "foo", class: "bar" do
  hr class: "hr-class"
end
```

returns

```html
<div id="foo" class="bar">
  <hr class="hr-class">
</div>
```
