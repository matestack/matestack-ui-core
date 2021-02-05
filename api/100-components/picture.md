# Matestack Core Component: Picture

The HTML `<picture>` tag, implemented in Ruby.

## Parameters

This component can take 2 optional configuration params and yield the passed content.

### id \(optional\)

Expects a string with all ids the `<picture>` should have.

### class \(optional\)

Expects a string with all classes the `<picture>` should have.

## Example: Yield a given block

```ruby
picture id: 'foo', class: 'bar' do
  img path: 'matestack-logo.png'
end
```

returns

```markup
<picture id="foo" class="bar">
  <img src="/assets/matestack-logo-XXXX.png" />
</picture>
```

