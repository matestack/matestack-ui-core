# matestack core component: Optgroup

Show [specs](/spec/usage/components/optgroup_spec.rb)

The HTML `<optgroup>` tag implemented in ruby.

## Parameters

This component can take 4 optional configuration params and yield the passed content.

#### # id (optional)
Expects a string with all ids the `<optgroup>` should have.

#### # class (optional)
Expects a string with all classes the `<optgroup>` should have.

#### # disabled (optional)
Specifies that the `<optgroup>` should be disabled.

#### # label (optional)
Specifies a label for the `<optgroup>`.

## Example: Yield a given block

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
