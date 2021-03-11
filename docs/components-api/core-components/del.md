# Del

The HTML `<del>` tag, implemented in Ruby.

## Parameters

This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### Cite \(optional\)

Expects a string with a URL to a document that explains the reason why the text was deleted.

### Datetime optional

Expects a string which specifies the date and time of when the text was deleted.

### Text \(optional\)

Expects a string which will be displayed as the content inside the `<dd>` tag.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
del id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```markup
<del id="foo" class="bar">
  Hello World
</del>
```

### Example 2: Render options\[:text\] param

```ruby
del id: "foo", class: "bar", text: 'Hello World'
```

returns

```markup
<del id="foo" class="bar">
  Hello World
</del>
```

