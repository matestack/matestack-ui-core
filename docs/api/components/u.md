# matestack core component: U

Show [specs](/spec/usage/components/u_spec.rb)

The HTML `<u>` tag implemented in Ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the u should have.

#### # class (optional)
Expects a string with all classes the u should have.


## Example 1
Adding an optional id

```ruby
div id: "foo", class: "bar" do
  u id: "u-id" do
    plain 'Example text'
  end
end
```

returns

```html
<div id="foo" class="bar">
  <u id="u-id">Example text</u>
</div>
```

## Example 2
Adding an optional class

```ruby
div id: "foo", class: "bar" do
  u class: "u-class", text: 'Example text'
end
```

returns

```html
<div id="foo" class="bar">
  <u class="u-class">Example text</u>
</div>
```
