# basemate core component: Div

Show [specs](../../spec/usage/components/div_spec.rb)

The HTML div tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the div should have.

#### # class (optional)
Expects a string with all classes the div should have.

## Example

```ruby
div id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<div id="foo" class="bar">
  Hello World
</div>
```
