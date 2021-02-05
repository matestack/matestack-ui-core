# Matestack Core Component: Paragraph

The HTML `<p>` tag, implemented in Ruby. This is a workaround because the single `p` is a [`Kernel` method in Ruby](https://ruby-doc.org/core-2.6.5/Kernel.html#method-i-p) (directly writes `obj.inspect` followed by a newline to the program’s standard output, e.g. `p foo` equals `puts foo.inspect`).

Alias: `pg`

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Text (optional)
Expects a string which will be displayed as the content inside the `<p>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
paragraph do
  plain "Hello World"
end
```

returns

```html
<p>Hello World</p>
```

### Example 2: Render options[:text] param

```ruby
paragraph text: "Hello World"
```

returns

```html
<p>Hello World</p>
```

## Example 3: Rendering another component inside

```ruby
paragraph id: "foo", class: "bar" do
  span text: "Hello World"
end
```

returns

```html
<p id="foo" class="bar">
  <span>Hello World</span>
</p>
```
