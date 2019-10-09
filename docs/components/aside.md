# matestack core component: Aside

Show [specs](/spec/usage/components/aside_spec.rb)

The HTML `<aside>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the aside tag should have.

#### # class (optional)
Expects a string with all classes the aside tag should have.

## Example 1

```ruby
aside id: "foo", class: "bar" do
  paragraph text: "This is some text"
end
```

returns

```html
<aside id="foo" class="bar">
  <p>This is some text</p>
</aside>
```
