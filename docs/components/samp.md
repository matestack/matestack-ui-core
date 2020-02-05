# matestack core component: Samp

Show [specs](/spec/usage/components/samp_spec.rb)

The HTML `<samp>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<samp>` should have.

#### # class (optional)
Expects a string with all classes the `<samp>` should have.

## Example 1: Yield a given block

```ruby
samp id: 'foo', class: 'bar' do
  plain 'Samp example 1' # optional content
end
```

returns

```html
<samp id="foo" class="bar">
  Samp example 1
</samp>
```

## Example 2: Render `options[:text]` param

```ruby
samp id: 'foo', class: 'bar', text: 'Samp example 2'
```

returns

```html
<samp id="foo" class="bar">
  Samp example 2
</samp>
