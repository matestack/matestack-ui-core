# Matestack Core Component: Q

The HTML `<q>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/q_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Cite - optional
Expects a string for referencing the source for the quote.

### Text - optional
Expects a string which will be displayed as the content inside the `<q>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
q id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<q id="foo" class="bar">
  Hello World
</q>
```

### Example 2: Render options[:text] param and using options[:cite]

```ruby
q id: "foo", class: "bar", cite: "helloworld.io" text: 'Hello World'
```

returns

```html
<q id="foo" class="bar" cite="helloworld.io">
  Hello World
</q>
```
