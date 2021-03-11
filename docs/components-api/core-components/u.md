# U

The HTML `<u>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### text \(optional\)

Expects a string which will be displayed as the content inside the `<address>`. If this is not passed, a block must be passed instead.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
u id: "u-id" do
  plain 'Example text'
end
```

returns

```markup
<u id="u-id">Example text</u>
```

### Example 2: Render options\[:text\] param

```ruby
u class: "u-class", text: 'Example text'
```

returns

```markup
<u class="u-class">Example text</u>
```

