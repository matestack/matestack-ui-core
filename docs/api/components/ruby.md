# matestack core component: Ruby

Show [specs](/spec/usage/components/ruby_spec.rb)

The HTML ruby tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the ruby should have.

#### # class (optional)
Expects a string with all classes the ruby should have.

## Example 1: : Yield a given block

```ruby
ruby id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<ruby id="foo" class="bar">
  Hello World
</ruby>
```

## Example 2: Render options[:text] param

```ruby
ruby id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<ruby id="foo" class="bar">
  Hello World
</ruby>
