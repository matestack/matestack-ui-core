# Matestack Core Component: Button

The HTML `<button>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/button_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can handle various optional configuration params and can either yield content or display what gets passed to the `text` configuration param.

### Disabled - optional
Expects a boolean to specify a disabled `<button>` tag. Defaults to `false`, so if not specified otherwise buttons are **not disabled**.

### Text - optional
Expects a string with the text that should go inside the `<button>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Render options[:text] param

```ruby
button text: 'Click me'
```

returns

```html
<button>Click me</button>
```

### Example 2: Yield a given block

```ruby
button id: 'foo', class: 'bar' do
  plain "Click me"
end
```

returns

```html
<button id="foo" class="bar">Click me</button>
```

### Example 3: Using the options[:disabled] configuration

```ruby
button disabled: true, text: 'You can not click me'
button disabled: false, text: 'You can click me'
button text: 'You can click me too'
```

returns

```html
<button disabled="disabled">You can not click me</button>
<button>You can click me</button>
<button>You can click me too</button>
```
