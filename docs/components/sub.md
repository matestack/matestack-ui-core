# matestack core component: Sub

Show [specs](../../spec/usage/components/sub_spec.rb)

The HTML sub tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the sub should have.

#### # class (optional)
Expects a string with all classes the sub should have.

#### # text (optional)
Expects a string with the text that should go into the `<sub>` tag.

## Example 1: Yield a given block

```ruby
sub id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<sub id="foo" class="bar">
  Hello World
</sub>
```

## Example 2: Render options[:text] param

```ruby
sub id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<sub id="foo" class="bar">
  Hello World
</sub>
