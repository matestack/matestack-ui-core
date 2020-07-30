# matestack core component: B

Show [specs](/spec/usage/components/b_spec.rb)

The HTML b tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the b should have.

#### # class (optional)
Expects a string with all classes the b should have.

## Example 1: Yield a given block

```ruby
b id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<b id="foo" class="bar">
  Hello World
</b>
```

## Example 2: Render options[:text] param

```ruby
b id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<b id="foo" class="bar">
  Hello World
</b>
