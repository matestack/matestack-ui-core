# basemate core component: Header

The HTML header tag implemented in ruby.

## Parameters

This component expects 2 optional configuration params and optional content.

#### # id
Expects a string with all ids the header should have.

#### # class
Expects a string with all classes the header should have.

## Example

```ruby
header id: "foo", class: "bar" do
  plain 'Hello World' #optional content
end
```

returns

```html
<header id="foo" class="bar">
  Hello World
</header>
```
