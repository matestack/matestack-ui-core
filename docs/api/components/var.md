# Matestack Core Component: Var

The HTML `<var>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/var_spec.rb) and see the [examples](#examples) below.

## Parameters
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
var id: "foo", class: "bar" do
  plain 'Simple text'
end
```

returns

```html
<var id="foo" class="bar">
  Simple text
</var>
```

### Example 2: Render options[:text] param

```ruby
var id: "foo", class: "bar", text: 'Simple text'
```

returns

```html
<var id="foo" class="bar">
  Simple text
</var>
```
