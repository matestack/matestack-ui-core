# basemate core component: Section

Show [specs](../../spec/usage/components/section_spec.rb)

The HTML section tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the section should have.

#### # class (optional)
Expects a string with all classes the section should have.

## Example

```ruby
section id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<section id="foo" class="bar">
  Hello World
</section>
```
