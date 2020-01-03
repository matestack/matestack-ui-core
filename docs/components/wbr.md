# matestack core component: Wbr

Show [specs](/spec/usage/components/wbr_spec.rb)

The HTML `<wbr>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params.

#### # id (optional)
Expects a string with all ids the `<wbr>` should have.

#### # class (optional)
Expects a string with all classes the `<wbr>` should have.

## Example 1: Usage

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
