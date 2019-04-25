# basemate core component: Nav

The HTML nav tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the nav should have.

#### # class (optional)
Expects a string with all classes the nav should have.

## Example

```ruby
nav id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<nav id="foo" class="bar">
  Hello World
</nav>
```
