# matestack core component: Datalist

Show [specs](/spec/usage/components/datalist_spec.rb)

The HTML `<datalist>` tag implemented in Ruby.

## Parameters

This component can take 2 optional configuration params and yield content.

#### # id (optional)
Expects a string with all ids the datalist should have.

#### # class (optional)
Expects a string with all classes the datalist should have.


## Example 1
Adding an optional id

```ruby
datalist id: 'foo', class: 'bar' do
  plain 'Example Text'
end
```

returns

```html
<datalist id="foo" class="bar">Example Text</datalist>
```
