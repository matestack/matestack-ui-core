# Matestack Core Component: U

The HTML `<u>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/u_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<address>`. If this is not passed, a block must be passed instead.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
u id: "u-id" do
  plain 'Example text'
end
```

returns

```html
<u id="u-id">Example text</u>
```

### Example 2: Render options[:text] param

```ruby
u class: "u-class", text: 'Example text'
```

returns

```html
<u class="u-class">Example text</u>
```
