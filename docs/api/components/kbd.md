# Matestack Core Component: kbd

The HTML `<kbd>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/kbd_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<kbd>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
kbd id: 'foo', class: 'bar' do
  plain 'Keyboard input' # optional content
end
```

returns

```html
<kbd id="foo" class="bar">
  Keyboard input
</kbd>
```

### Example 2: Render `options[:text]` param

```ruby
kbd id: 'foo', class: 'bar', text: 'Keyboard input'
```

returns

```html
<kbd id="foo" class="bar">
  Keyboard input
</kbd>
```
