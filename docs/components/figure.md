# matestack core component: Figure

Show [specs](/spec/usage/components/figure_spec.rb)

The HTML `<figure>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the figure tag should have.

#### # class (optional)
Expects a string with all classes the figure tag should have.

## Example 1

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
