# Matestack Core Component: Optgroup

The HTML `<optgroup>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and yields a block.

### Disabled (optional)
Expects a boolean to specify if the `<optgroup>` should be disabled. Defaults to `false`, so if not specified otherwise optgroups are **not disabled**.

### Label (optional)
Expects a string which will be displayed as the label inside the `<optgroup>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
optgroup label: 'Swedish Cars' do
  option text: 'Volvo', value: 'volvo'
  option text: 'Saab', value: 'saab'
end
```

returns

```html
<optgroup label="Swedish Cars">
  <option value="volvo">Volvo</option>
  <option value="saab">Saab</option>
</optgroup>
```

### Example 2: Using disabled configuration

```ruby
optgroup label: 'Disabled Group', disabled: true, id: 'disabled-group' do
  option text: 'Option J'
  option text: 'Option K'
  option text: 'Option L'
end
```

returns

```html
<optgroup disabled="disabled" id="disabled-group" label="Disabled Group">
  <option>Option J</option>
  <option>Option K</option>
  <option>Option L</option>
</optgroup>
```
