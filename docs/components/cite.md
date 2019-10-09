# matestack core component: Cite

Show [specs](/spec/usage/components/cite_spec.rb)

The HTML cite tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the cite tag should have.

#### # class (optional)
Expects a string with all classes the cite tag should have.

## Example 1: Yield a given block

```ruby
cite id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<cite id="foo" class="bar">
  Hello World
</cite>
```

## Example 2: Render options[:text] param

```ruby
cite id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<cite id="foo" class="bar">
  Hello World
</cite>
