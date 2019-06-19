# matestack core component: Span

Show [specs](../../spec/usage/components/span_spec.rb)

The HTML span tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the span should have.

#### # class (optional)
Expects a string with all classes the span should have.

## Example 1: Yield a given block

```ruby
span id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<span id="foo" class="bar">
  Hello World
</span>
```

## Example 2: Render options[:text] param

```ruby
span id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<span id="foo" class="bar">
  Hello World
</span>
```
