# Matestack Core Component: Small

The HTML `<small>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/small_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<small>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
small id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<small id="foo" class="bar">Hello World</small>
```

### Example 2: Render options[:text] param

```ruby
small id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<small id="foo" class="bar">Hello World</small>
```
