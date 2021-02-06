# Blockquote

The HTML `<blockquote>` tag, implemented in Ruby.

## Parameters

This component can handle various optional configuration params and can either yield content or display what gets passed to the `text` configuration param.

### Cite \(optional\)

Expects a string referencing a cite for the blockquote.

### Text \(optional\)

Expects a string which will be displayed as the content inside the `<blockquote>` tag. If this is not passed, a block must be passed instead.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
blockquote id: "foo", class: "bar", cite: "this is a cite" do
  plain 'Hello World' # optional content
end
```

returns

```markup
<blockquote cite="this is a cite" id="foo" class="bar">
  Hello World
</blockquote>
```

### Example 2: Render options\[:text\] param

```ruby
blockquote id: "foo", class: "bar", cite: "this is a cite", text: 'Hello World'
```

returns

```markup
<blockquote cite="this is a cite" id="foo" class="bar">
  Hello World
</blockquote>
```

