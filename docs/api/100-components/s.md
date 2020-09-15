# Matestack Core Component: S

The HTML `<s>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### text (optional)
Expects a string which will be displayed as the content inside the `<s>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: : Yield a given block

```ruby
s id: "foo", class: "bar" do
  plain "Hello World"
end
```

returns

```html
<s id="foo" class="bar">Hello World</s>
```

### Example 2: Render options[:text] param

Specifying the text directly

```ruby
s id: "foo", class: "bar" text: "Hello World"
```

returns

```html
<s id="foo" class="bar">Hello World</s>
```
