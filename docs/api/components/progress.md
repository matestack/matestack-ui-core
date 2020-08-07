# Matestack Core Component: Progress

The HTML `<progress>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/progress_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Max - optional
Expects an integer and sets the maximum value of the `<progress>` tag.

### Value - optional
Expects an integer with a value equal to or below the `max` param.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
progress id: 'my-id', class: 'my-class', value: 33, max: 330
```

returns

```html
<progress id="my-id" max="330" value="33" class="my-class"></progress>
```

### Example 2: Default value of 0 if none is set

```ruby
progress max: 500
```

returns

```html
<progress max="500" value="0"></progress>
```
