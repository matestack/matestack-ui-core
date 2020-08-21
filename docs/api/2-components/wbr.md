# Matestack Core Component: Wbr

The HTML `<wbr>` tag, implemented in Ruby.

## Parameters
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
paragraph do
  plain 'First part of text'
  wbr id: 'foo', class: 'bar'
  plain 'Second part of text'
end
```

returns

```html
<p>First part of text<wbr id="foo" class="bar">Second part of text</p>
```
