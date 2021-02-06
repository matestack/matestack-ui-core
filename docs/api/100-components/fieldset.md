# Fieldset

The HTML `<fieldset>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and yield a block.

### Disabled \(optional\)

Expects a boolean. If set to true, the `<fieldset>` will be disabled.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
fieldset id: 'foo', class: 'bar' do
  legend id: 'baz', text: 'Your Inputs for Personal details'
  label text: 'Personal Detail'
  input
end
```

```markup
<fieldset id="foo" class="bar">
  <legend id="baz">Your Inputs for Personal details</legend>
  <label>Personal Detail</label>
  <input>
</fieldset>
```

### Example 2: Disabled Attributes

```ruby
fieldset disabled: true do
  legend text: 'input legend'
  input
end
```

```markup
<fieldset disabled="disabled">
  <legend>input legend</legend>
  <input>
</fieldset>
```

