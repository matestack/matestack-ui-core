# matestack core component: Q

Show [specs](../../spec/usage/components/q_spec.rb)

The HTML q tag implemented in ruby.

## Parameters

This component can take 4 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the quote should have.

#### # class (optional)
Expects a string with all classes the quote should have.

#### # text (optional)
Expects a string with the text that should go into the `<q>` tag.

#### # cite (optional)
Expects a string for referencing the source for the quote.

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
q id: "foo", class: "bar", cite: "helloworld.io" text: 'Hello World'
```

returns

```html
<q id="foo" class="bar" cite="helloworld.io">
  Hello World
</q>
