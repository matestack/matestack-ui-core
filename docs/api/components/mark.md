# Matestack Core Component: Mark

The HTML `<mark>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/mark_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text (optional)
Expects a string which will be displayed as the content inside the `<mark>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
mark id: 'foo', class: 'bar' do
  plain 'Mark Example 1' # optional content
end
```

returns

```html
<mark id="foo" class="bar">
  Mark Example 1
</mark>
```

### Example 2: Render `options[:text]` param

```ruby
mark id: 'foo', class: 'bar', text: 'Mark Example 2'
```

returns

```html
<mark id="foo" class="bar">
  Mark Example 2
</mark>
```
