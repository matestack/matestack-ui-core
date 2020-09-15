# Matestack Core Component: Dfn

The HTML `<dfn>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text (optional)
Expects a string which will be displayed as the content inside the `<dfn>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
dfn id: "dfn-id" do
  plain 'Example'
end
```

returns

```html
<dfn id="dfn-id">Example</dfn>
```

### Example 2: Render options[:text] param

```ruby
dfn class: "dfn-class", text: 'Example'
```

returns

```html
<dfn class="dfn-class">Example</dfn>
```
