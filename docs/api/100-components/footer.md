# Matestack Core Component: Footer

The HTML `<footer>` tag, implemented in Ruby.

## Parameters

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

## Example 1: Basic usage

```ruby
footer id: "foo", class: "bar" do
  plain 'Hello World' #optional content
end
```

returns

```markup
<footer id="foo" class="bar">
  Hello World
</footer>
```

