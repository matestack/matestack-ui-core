# matestack core component: Picture

Show [specs](/spec/usage/components/picture_spec.rb)

The HTML `<picture>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and yield the passed content.

#### # id (optional)
Expects a string with all ids the `<picture>` should have.

#### # class (optional)
Expects a string with all classes the `<picture>` should have.

## Example: Yield a given block

```ruby
picture id: 'foo', class: 'bar' do
  img path: 'matestack-logo.png'
end
```

returns

```html
<picture id="foo" class="bar">
  <img src="/assets/matestack-logo-XXXX.png" />
</picture>
```
