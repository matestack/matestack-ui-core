# Datalist

The HTML `<datalist>` tag, implemented in Ruby.

## Parameters

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1 - Basic usage

```ruby
datalist id: 'foo', class: 'bar' do
  plain 'Example Text'
end
```

returns

```markup
<datalist id="foo" class="bar">Example Text</datalist>
```

