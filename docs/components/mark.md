# matestack core component: Mark

Show [specs](/spec/usage/components/mark_spec.rb)

The HTML `<mark>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<mark>` should have.

#### # class (optional)
Expects a string with all classes the `<mark>` should have.

## Example 1: Yield a given block

```ruby
mark id: 'foo', class: 'bar' do
  plain 'Mark Example 1' # optional content
end
```

returns

```html
<mark id="foo" class="bar">
  Mark Example 1
</mark>
```

## Example 2: Render `options[:text]` param

```ruby
mark id: 'foo', class: 'bar', text: 'Mark Example 2'
```

returns

```html
<mark id="foo" class="bar">
  Mark Example 2
</mark>
