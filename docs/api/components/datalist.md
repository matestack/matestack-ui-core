# Matestack Core Component: Datalist

The HTML `<datalist>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/datalist_spec.rb) and see the [examples](#examples) below.

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

```html
<datalist id="foo" class="bar">Example Text</datalist>
```
