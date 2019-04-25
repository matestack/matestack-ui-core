# basemate core component: Span

The HTML span tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the span should have.

#### # class (optional)
Expects a string with all classes the span should have.

## Example

```ruby
span id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<span id="foo" class="bar">
  Hello World
</span>
```
