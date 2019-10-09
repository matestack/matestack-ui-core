# matestack core component: Rp

Show [specs](/spec/usage/components/rp_spec.rb)

The HTML rp tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the rp should have.

#### # class (optional)
Expects a string with all classes the rp should have.

## Example 1: Yield a given block

```ruby
rp id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<rp id="foo" class="bar">
  Hello World
</rp>
```

## Example 2: Render options[:text] param

```ruby
rp id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<rp id="foo" class="bar">
  Hello World
</rp>
