# Matestack Core Component: Code

The HTML `<code>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/code_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<code>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
code id: "foo", class: "bar" do
  plain 'puts "Hello Mate One"'
end
```

returns

```html
<code id="foo" class="bar">
  puts "Hello Mate One"
</code>
```

### Example 2: Render options[:text] param

```ruby
code id: "foo", class: "bar", text: 'puts "Hello Mate Two"'
```

returns

```html
<code id="foo" class="bar">
  puts "Hello Mate Two"
</code>
```
