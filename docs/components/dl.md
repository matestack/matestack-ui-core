# matestack core component: Dl

Show [specs](/spec/usage/components/dl_spec.rb)

The HTML dl tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `dl` should have.

#### # class (optional)
Expects a string with all classes the `dl` should have.

## Example 1: Yield a given block

```ruby
dl id: "foo", class: "bar" do
  dt text: "dt component"
  dd text: "dd component"
end
```

returns

```html
<dl id="foo" class="bar">
  <dt>dt component</dt>
  <dd>dd component</dd>
</dl>
```

## Example 2: Render options[:text] param

```ruby
dl id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<dl id="foo" class="bar">
  Hello World
</dl>
```