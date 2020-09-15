# Matestack Core Component: Label

The HTML `<label>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### For (optional)
Expects a string that binds the label to a given form element (matches `id` of form element).

### Form (optional)
Expects a string that specifies which form or forms the label belongs to.

### Text (optional)
Expects a string which will be displayed as the content inside the `<label>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
label id: "foo", class: "bar", for: 'input_id', form: 'form1' do
  plain 'Label For Element'
end
```

returns

```html
<label for="input_id" id="foo" class="bar">
  Label For Element
</label>
```

### Example 2: Render `options[:text]` param

```ruby
label id: 'foo', form: 'form1', text: "Label for form with id='form1'"
```

returns

```html
<label form="form1" id="foo">Label for form with id='form1'</label>
```
