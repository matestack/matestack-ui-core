# matestack core component: Small

Show [specs](/spec/usage/components/small_spec.rb)

The HTML small tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the small tag should have.

#### # class (optional)
Expects a string with all classes the small tag should have.

## Example 1: Yield a given block

```ruby
small id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<small id="foo" class="bar">Hello World</small>
```

## Example 2: Render options[:text] param

```ruby
small id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<small id="foo" class="bar">Hello World</small>
