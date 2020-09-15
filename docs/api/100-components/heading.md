# Matestack Core Component: Heading

The HTML `<h1>, <h2>, <h3>, <h4>, <h5>, <h6>` tags, implemented in Ruby.


## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Size (optional)
Expects an integer, from 1 to 6. If not set, it defaults to 1 and creates and `<h1>` tag.

### Text (optional)
Expects a string which will be displayed as the content inside the `<h(1-6)>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

## Example 1: Basic usage

```ruby
heading size: 1, text: 'Heading, size 1'
heading size: 2, text: 'Heading, size 2'
heading size: 3, text: 'Heading, size 3'
heading size: 4, text: 'Heading, size 4'
heading size: 5, text: 'Heading, size 5'
heading size: 6, text: 'Heading, size 6'
heading text: 'Heading, default size 1'
```

returns

```html
<h1>Heading, size 1</h1>
<h2>Heading, size 2</h2>
<h3>Heading, size 3</h3>
<h4>Heading, size 4</h4>
<h5>Heading, size 5</h5>
<h6>Heading, size 6</h6>
<h6>Heading, default size 1</h6>
```

### Example 1: Yield a given block

```ruby
heading id: "foo", class: "bar" do
  plain "Hello World"
end
```

returns

```html
<h1 id="foo" class="bar">Hello World</h1>
```

### Example 2: Render options[:text] param

```ruby
heading id: "foo", class: "bar", text: "Hello World"
```

returns

```html
<h1 id="foo" class="bar">Hello World</h1>
```
