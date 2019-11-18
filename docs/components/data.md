# matestack core component: Data

Show [specs](/spec/usage/components/data_spec.rb)

The HTML `<data>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<data>` should have.

#### # class (optional)
Expects a string with all classes the `<data>` should have.

#### # value (optional)
Expects a string and specifies the machine-readable translation of the content of the `<data>` element.

## Example 1: Yield a given block

```ruby
data id: 'foo', class: 'bar', value: '1300' do
  plain 'Data example 1' # optional content
end
```

returns

```html
<data id="foo" class="bar" value="1300">
  Data example 1
</data>
```

## Example 2: Render `options[:text]` param

```ruby
data id: 'foo', class: 'bar', value: '1301', text: 'Data example 2'
```

returns

```html
<data id="foo" class="bar" value="1301">
  Data example 2
</data>
