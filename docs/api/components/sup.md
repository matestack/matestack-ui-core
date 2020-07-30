# matestack core component: Sup

Show [specs](../../spec/usage/components/sup_spec.rb)

The HTML sup tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)

Expects a string with all ids the sup should have.

#### # class (optional)

Expects a string with all classes the sup should have.

#### # text (optional)

Expects a string with the text that should go into the `<sup>` tag.

## Example 1: Yield a given block

```ruby
sup id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<sup id="foo" class="bar">
  Hello World
</sup>
```

## Example 2: Render options[:text] param

```ruby
sup id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<sup id="foo" class="bar">
  Hello World
</sup>
```
