# Matestack Core Component: Ins
The HTML `<ins>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/ins_spec.rb) and see the [examples](#examples) below.

## Parameters
This component can take various optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### Cite - optional
Expects a string with a URL to a document that explains the reason why the text was inserted/changed.

### Datetime - optional
Expects a string which specifies the date and time of when the text was inserted/changed.

### Text - optional
Expects a string which will be displayed as the content inside the `<ins>` tag.

### HMTL attributes - optional
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Yield a given block

```ruby
ins id: "foo", class: "bar", cite: "example.html", datetime: "2008-05-25T17:25:00Z" do
  plain 'Inserted text' # optional content
end
```

returns

```html
<ins id="foo" class="bar" cite="example.html" datetime="2008-05-25T17:25:00Z">Inserted text</ins>
```

### Example 2: Render options[:text] param

```ruby
ins id: "foo", class: "bar", cite: "example.html", datetime: "2008-05-25T17:25:00Z", text: 'Inserted text'
```

returns

```html
<ins id="foo" class="bar" cite="example.html" datetime="2008-05-25T17:25:00Z">Inserted text</ins>
```
