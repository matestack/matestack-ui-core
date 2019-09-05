# matestack core component: Blockquote

Show [specs](/spec/usage/components/blockquote_spec.rb)

The HTML blockquote tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the span should have.

#### # class (optional)
Expects a string with all classes the span should have.

#### # cite (optional)
Expects a string referencing a cite for the blockquote.

## Example 1: Yield a given block

```ruby
blockquote id: "foo", class: "bar", cite: "this is a cite" do
  plain 'Hello World' # optional content
end
```

returns

```html
<blockquote cite="this is a cite" id="foo" class="bar">
  Hello World
</blockquote>
```

## Example 2: Render options[:text] param

```ruby
blockquote id: "foo", class: "bar", cite: "this is a cite", text: 'Hello World'
```

returns

```html
<blockquote cite="this is a cite" id="foo" class="bar">
  Hello World
</blockquote>
```
