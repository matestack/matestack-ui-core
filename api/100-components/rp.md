# Matestack Core Component: Rp

The HTML `<rp>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### text \(optional\)

Expects a string which will be displayed as the content inside the `<rp>` tag.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
rp id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```markup
<rp id="foo" class="bar">
  Hello World
</rp>
```

### Example 2: Render options\[:text\] param

```ruby
rp id: "foo", class: "bar", text: 'Hello World'
```

returns

```markup
<rp id="foo" class="bar">
  Hello World
</rp>
```

