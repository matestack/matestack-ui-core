# Matestack Core Component: Address

The HTML `<address>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/address_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<address>` tag. If this is not passed, a block must be passed instead.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1 - yield a given block

```ruby
address do
  plain 'Codey McCodeface'
  br
  plain '1 Developer Avenue'
  br
  plain 'Techville'
end
```

returns

```html
<address>
  Codey McCodeface<br>
  1 Developer Avenue<br>
  Techville
</address>
```

### Example 2 - render options[:text] param

```ruby
address text: 'PO Box 12345'
```

returns

```html
<address>
  PO Box 12345
</address>
```
