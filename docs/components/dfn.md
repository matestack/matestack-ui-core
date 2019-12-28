# matestack core component: Dfn

Show [specs](/spec/usage/components/dfn_spec.rb)

The HTML `<dfn>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the dfn should have.

#### # class (optional)
Expects a string with all classes the dfn should have.

## Example 1
Adding an optional id

```ruby
div id: "foo", class: "bar" do
  dfn id: "dfn-id" do
    plain 'Example'
  end
end
```

returns

```html
<div id="foo" class="bar">
  <dfn id="dfn-id">Example</dfn>
</div>
```

## Example 2
Adding an optional class

```ruby
div id: "foo", class: "bar" do
  dfn class: "dfn-class", text: 'Example'
end
```

returns

```html
<div id="foo" class="bar">
  <dfn class="dfn-class">Example</dfn>
</div>
```
