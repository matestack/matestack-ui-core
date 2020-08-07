# Matestack Core Component: Input

Feel free to check out the [component specs](/spec/usage/components/input_spec.rb).

The HTML textarea tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<sub>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
textarea id: "foo", class: "bar", cols: 2, maxlength: 20 do
  plain 'Hello World!'
end

```

returns

```html
<textarea type="text" id="foo" class="bar" cols="2" maxlength="20">Hello World!</textarea>
```

### Example 2: Render options[:text] param

```ruby
textarea id: "foo", class: "bar", cols: 2, maxlength: 20, text: 'Hello World!'
```

returns

```html
<textarea type="text" id="foo" class="bar" cols="2" maxlength="20">Hello World!</textarea>
```
