# Matestack Core Component: Aside

The HTML `<aside>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text \(optional\)

Expects a string which will be displayed as the content inside the `<aside>` tag. If this is not passed, a block must be passed instead.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1 - Basic usage

```ruby
aside id: "foo", class: "bar" do
  paragraph text: "This is some text"
end
```

returns

```markup
<aside id="foo" class="bar">
  <p>This is some text</p>
</aside>
```

