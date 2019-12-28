# matestack core component: Dialog

Show [specs](/spec/usage/components/dialog_spec.rb)

The HTML `<dialog>` tag implemented in Ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<dialog>` should have.

#### # class (optional)
Expects a string with all classes the `<dialog>` should have.

## Example 1: Yield a given block

```ruby
dialog id: 'foo', class: 'bar' do
  plain 'Dialog example 1' # optional content
end
```

returns

```html
<dialog id="foo" class="bar">
  Dialog example 1
</dialog>
```

## Example 2: Render `options[:text]` param

```ruby
dialog id: 'foo', class: 'bar', text: 'Dialog example 2'
```

returns

```html
<dialog id="foo" class="bar">
  Dialog example 2
</dialog>
```
