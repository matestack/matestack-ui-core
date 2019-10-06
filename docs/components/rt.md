# matestack core component: Rt

Show [specs](/spec/usage/components/rt_spec.rb)

The HTML rt tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the main should have.

#### # class (optional)
Expects a string with all classes the main should have.

## Example

```ruby
rt id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<rt id="foo" class="bar">
  Hello World
</rt>
```
