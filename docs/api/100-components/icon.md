# Matestack Core Component: Icon

The HTML `<i>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text (optional)
Expects a string which will be displayed as the content inside the `<i>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Rendering a Font Awesome icon

```ruby
icon id: "foo", class: "fa fa-car"
```

returns

```html
<i id="foo" class="fa fa-car"></i>
```

### Example 2: Rendering a Material Design icon

```ruby
icon id: "foo", class: "material-icons", text: "accessibility"
```

returns

```html
<i id="foo" class="material-icons">accessibility</i>
```
