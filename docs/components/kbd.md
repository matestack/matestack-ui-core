# matestack core component: kbd

Show [specs](/spec/usage/components/kbd_spec.rb)

The HTML kbd tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the kbd should have.

#### # class (optional)
Expects a string with all classes the kbd should have.

## Example 1: Yield a given block

```ruby
kbd id: 'foo', class: 'bar' do
  plain 'Keyboard input' # optional content
end
```

returns

```html
<kbd id="foo" class="bar">
  Keyboard input
</kbd>
```

## Example 2: Render `options[:text]` param

```ruby
kbd id: 'foo', class: 'bar', text: 'Keyboard input'
```

returns

```html
<kbd id="foo" class="bar">
  Keyboard input
</kbd>
