# matestack core component: Blockquote

Show [specs](../../spec/usage/components/article_spec.rb)

The HTML article tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the span should have.

#### # class (optional)
Expects a string with all classes the span should have.

#### # text - optional
Expects a string which will be displayed as the content inside the `article`. If this is not passed, a block must be passed instead.

## Example 1: Yield a given block

```ruby
article do
  paragraph text: "Hello world"
end
```

returns

```html
<article>
  <p>Hello world</p>
</article>
```

## Example 2: Render options[:text] param

```ruby
article text: "Hello world"
```

returns

```html
<article>Hello world</article>
```
