# matestack core component: Legend

Show [specs](/spec/usage/components/legend_spec.rb)

The HTML legend tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the legend should have.

#### # class (optional)
Expects a string with all classes the legend should have.

## Example 1: Yield a given block

```ruby
legend id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<legend id="foo" class="bar">
  Hello World
</legend>
```

## Example 2: Render options[:text] param

```ruby
legend id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<legend id="foo" class="bar">
  Hello World
</legend>
