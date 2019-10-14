# matestack core component: Noscript

Show [specs](/spec/usage/components/noscript_spec.rb)

The HTML noscript tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the noscript should have.

#### # class (optional)
Expects a string with all classes the noscript should have.

## Example 1: Yield a given block

```ruby
noscript id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<noscript id="foo" class="bar">
  Hello World
</noscript>
```

## Example 2: Render options[:text] param

```ruby
noscript id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<noscript id="foo" class="bar">
  Hello World
</noscript>

