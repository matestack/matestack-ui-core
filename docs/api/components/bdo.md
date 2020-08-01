# Matestack Core Component: Bdo

The HTML `<bdo>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/bdo_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<bdo>` tag. If this is not passed, a block must be passed instead.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
bdo id: 'foo', class: 'bar' do
  plain 'example 1' # optional content
end
```

returns

```html
<bdo id="foo" class="bar">
  example 1
</bdo>
```

### Example 2: Render `options[:text]` param

```ruby
bdo id: 'foo', class: 'bar', text: 'example 2'
```

returns

```html
<bdo id="foo" class="bar">
  example 2
</bdo>
```
