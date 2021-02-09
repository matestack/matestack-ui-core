# Param

The HTML `<param>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Name \(optional\)

Expects a string and specifies the name of a parameter.

### Value \(optional\)

Expects a string and specifies the value of a parameter.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
param name: 'autoplay', value: 'true'
```

returns

```markup
<param name="autoplay" value="true">
```

### Example 2: Basic usage with `id` and `class`

```ruby
param name: 'autoplay', value: 'true', id: 'my-id', class: 'my-class'
```

returns

```markup
<param id="my-id" name="autoplay" value="true" class="my-class">
```

