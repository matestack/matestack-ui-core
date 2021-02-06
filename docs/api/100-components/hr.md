# Hr

The HTML `<hr>` tag, implemented in Ruby.

## Parameters

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
hr
hr id: "hr-id"
hr class: "hr-class"
hr id: "hr-id", class: "hr-class"
```

returns

```markup
<hr>
<hr id="hr-id">
<hr class="hr-class">
<hr id="hr-id" class="hr-class">
```

