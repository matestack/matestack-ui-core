# Select

The HTML `<select>` tag, implemented in Ruby.

If you want to use the `select` in context of a matestack `form`, please use `form_select` documented [here](form_select.md)

## Parameters

This component can take various optional configuration params and yield content

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage along with `option` components

```ruby
select id: "foo", class: "bar" do
  option label: 'Option 1', value: '1', selected: true
  option label: 'Option 2', value: '2'
  option label: 'Option 3', value: '3'
end
```

returns

```markup
<select id="foo" class="bar">
  <option  label="Option 1" selected="selected" value="1"></option>
  <option  label="Option 2" value="2"></option>
  <option  label="Option 3" value="3"></option>
</select>
```

