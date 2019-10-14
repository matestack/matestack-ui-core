# matestack core component: Dt

Show [specs](/spec/usage/components/dt_spec.rb)

The HTML dt tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `dt` should have.

#### # class (optional)
Expects a string with all classes the `dt` should have.

## Example 1: Yield a given block

```ruby
dt id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<dt id="foo" class="bar">
  Hello World
</dt>
```

## Example 2: Render options[:text] param

```ruby
dt id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<dt id="foo" class="bar">
  Hello World
</dt>
```

