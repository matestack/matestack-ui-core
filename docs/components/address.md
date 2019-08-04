# matestack core component: Address

Show [specs](../../spec/usage/components/address_spec.rb)

The HTML `<address>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the address should have.

#### # class (optional)
Expects a string with all classes the address should have.

## Example 1 - yield a given block

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

## Example 2 - render options[:text] param

```ruby
address text: 'PO Box 12345'
```

returns

```html
<address>
  PO Box 12345
</address>
```
