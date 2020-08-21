# Matestack Core Component: Legend

The HTML `<legend>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text (optional)
Expects a string which will be displayed as the content inside the `<legend>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
legend id: "foo", class: "bar" do
  plain 'Hello World'
end
```

returns

```html
<legend id="foo" class="bar">
  Hello World
</legend>
```

### Example 2: Render options[:text] param

```ruby
legend id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<legend id="foo" class="bar">
  Hello World
</legend>
```
