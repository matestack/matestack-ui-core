# Matestack Core Component: Input

The HTML `<input>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/input_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Input - optional
Expects a symbol with that specifies the input type.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage as text input

```ruby
input type: :text, id: "foo", class: "bar"
```

returns

```html
<input type="text" id="foo" class="bar" />
```

### Example 2: Email input

```ruby
input type: :email, id: "foo", class: "bar"
```

returns

```html
<input type="email" />
```

### Example 3: Range input

```ruby
input type: :range, attributes: { min: 0, max: 10, step: 0.5 }
```

returns

```html
<input max="10" min="0" step="0.5" type="range" />
```
