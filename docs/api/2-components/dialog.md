# Matestack Core Component: Dialog

The HTML `<dialog>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Open (optional)
Expects a boolean. If set to true, the `<dialog>` will be visible.

### Text (optional)
Expects a string which will be displayed as the content inside the `<dialog>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
dialog id: 'foo', class: 'bar' do
  plain 'Dialog example 1' # optional content
end
```

returns

```html
<dialog id="foo" class="bar">
  Dialog example 1
</dialog>
```

### Example 2: Render `options[:text]` param

```ruby
dialog id: 'foo', class: 'bar', text: 'Dialog example 2', open: true
```

returns

```html
<dialog id="foo" class="bar" open="open">
  Dialog example 2
</dialog>
```
