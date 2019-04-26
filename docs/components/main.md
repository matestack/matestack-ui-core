# matestack core component: Main

Show [specs](../../spec/usage/components/main_spec.rb)

The HTML main tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the main should have.

#### # class (optional)
Expects a string with all classes the main should have.

## Example

```ruby
main id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<main id="foo" class="bar">
  Hello World
</main>
```
