# matestack core component: Footer

Show [specs](/spec/usage/components/footer_spec.rb)

The HTML footer tag implemented in ruby.

## Parameters

This component expects 2 optional configuration params and optional content.

#### # id
Expects a string with all ids the footer should have.

#### # class
Expects a string with all classes the footer should have.

## Example

```ruby
footer id: "foo", class: "bar" do
  plain 'Hello World' #optional content
end
```

returns

```html
<footer id="foo" class="bar">
  Hello World
</footer>
```
