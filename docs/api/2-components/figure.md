# Matestack Core Component: Figure

The HTML `<figure>` tag, implemented in Ruby.

## Parameters
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
figure id: "foo", class: "bar" do
  img path: 'matestack-logo.png', width: 500, height: 300, alt: "logo"
end
```

returns

```html
<figure id="foo" class="bar">
  <img src="your-asset-path/matestack-logo.png" width="500" height="300" alt="logo"/>
</figure>
```
