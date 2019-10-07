# matestack core component: Em

Show [specs](/spec/usage/components/em_spec.rb)

The HTML em tag implemented in Ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the em tag should have.

#### # class (optional)
Expects a string with all classes the em tag should have.

## Example 1: Yield a given block

```ruby
em id: "foo", class: "bar" do
  plain 'Emphasized text' # optional content
end
```

returns

```html
<em id="foo" class="bar">Emphasized text</em>
```

## Example 2: Render options[:text] param

```ruby
em id: "foo", class: "bar", text: 'Emphasized text'
```

returns

```html
<em id="foo" class="bar">Emphasized text</em>
