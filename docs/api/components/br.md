# Matestack Core Component: Br

The HTML `<br>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/br_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can handle various optional configuration params and can either yield content or display what gets passed to the `text` configuration param.

### Times - optional
The number of times you want to repeat the spacing.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1 - Display single `<br>` tag

```ruby
paragraph text: "foo"
br
paragraph text: "bar"
```

returns

```html
<p>foo</p>
<br>
<p>bar</p>
```

### Example 2 - Display multiple `<br>` tags

```ruby
paragraph text: "foo"
br times: 3
paragraph text: "bar"
```

returns

```html
<p>foo</p>
<br>
<br>
<br>
<p>bar</p>
```
