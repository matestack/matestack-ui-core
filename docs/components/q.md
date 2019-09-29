# matestack core component: Q

Show [specs](../../spec/usage/components/q_spec.rb)

The HTML q tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the q should have.

#### # class (optional)
Expects a string with all classes the q should have.

#### # text (optional)
Expects a string with the text that should go into the `<q>` tag.

## Example 1: Yield a given block

```ruby
q id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<q id="foo" class="bar">
  Hello World
</q>
```

## Example 2: Render options[:text] param

```ruby
q id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<q id="foo" class="bar">
  Hello World
</q>
