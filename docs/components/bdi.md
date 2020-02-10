# matestack core component: Bdi

Show [specs](/spec/usage/components/bdi_spec.rb)

The HTML `<bdi>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<bdi>` should have.

#### # class (optional)
Expects a string with all classes the `<bdi>` should have.

## Example 1: Yield a given block

```ruby
bdi id: 'foo', class: 'bar' do
  plain 'Bdi example 1' # optional content
end
```

returns

```html
<bdi id="foo" class="bar">
  Bdi example 1
</bdi>
```

## Example 2: Render `options[:text]` param

```ruby
bdi id: 'foo', class: 'bar', text: 'Bdi example 2'
```

returns

```html
<bdi id="foo" class="bar">
  Bdi example 2
</bdi>
