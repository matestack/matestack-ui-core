# Caption

The HTML `<caption>` tag, implemented in Ruby.

## Parameters

This component can handle various optional configuration params and can either yield content or display what gets passed to the `text` configuration param.

### Text \(optional\)

Expects a string with the text that should go inside the `<caption>` tag.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Render options\[:text\] param

```ruby
table do
  caption text: "table caption"
  # table contents
end
```

returns

```markup
<table>
  <caption>table caption</caption>
  <!-- table contents -->
</table>
```

### Example 2: Yield a given block

```ruby
table id: 'foo', class: 'bar' do
  caption do
    plain "table caption"
  end
end
```

returns

```markup
<table id="foo" class="bar">
  <caption>table caption</caption>
</table>
```

