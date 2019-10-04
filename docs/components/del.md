# matestack core component: Del

Show [specs](/spec/usage/components/del_spec.rb)

The HTML del tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the span should have.

#### # class (optional)
Expects a string with all classes the span should have.

## Example 1: Yield a given block

```ruby
del id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<del id="foo" class="bar">
  Hello World
</del>
```

## Example 2: Render options[:text] param

```ruby
del id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<del id="foo" class="bar">
  Hello World
</del>
