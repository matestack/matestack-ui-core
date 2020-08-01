# Matestack Core Component: Samp

The HTML `<samp>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/samp_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text - optional
Expects a string which will be displayed as the content inside the `<samp>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
samp id: 'foo', class: 'bar' do
  plain 'Samp example 1' # optional content
end
```

returns

```html
<samp id="foo" class="bar">
  Samp example 1
</samp>
```

### Example 2: Render `options[:text]` param

```ruby
samp id: 'foo', class: 'bar', text: 'Samp example 2'
```

returns

```html
<samp id="foo" class="bar">
  Samp example 2
</samp>
```
