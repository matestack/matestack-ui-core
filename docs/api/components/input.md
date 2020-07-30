# matestack core component: Input

Show [specs](/spec/usage/components/input_spec.rb)

The HTML input tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the main should have.

#### # class (optional)
Expects a string with all classes the main should have.

#### # type (optional)
Expects a symbol with that specifies the input type.

## Example

```ruby
input type: :text, id: "foo", class: "bar"
```

returns

```html
<input type="text" id="foo" class="bar" />
```