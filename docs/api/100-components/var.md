# Var

The HTML `<var>` tag, implemented in Ruby.

## Parameters

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

### text - optional

If given will render the text within the var tags

## Examples

### Example 1: Yield a given block

```ruby
var id: "foo", class: "bar" do
  plain 'Simple text'
end
```

returns

```markup
<var id="foo" class="bar">
  Simple text
</var>
```

### Example 2: Render options\[:text\] param

```ruby
var id: "foo", class: "bar", text: 'Simple text'
```

returns

```markup
<var id="foo" class="bar">
  Simple text
</var>
```

