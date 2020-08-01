# Matestack Core Component: Nav

The HTML `<nav>` tag, implemented in Ruby.

Feel free to check out the [component specs](/spec/usage/components/nav_spec.rb) and see the [examples](#examples) below.

## Parameters
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
nav id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<nav id="foo" class="bar">
  Hello World
</nav>
```
