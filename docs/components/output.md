# matestack core component: Output

Show [specs](/spec/usage/components/output_spec.rb)

The HTML `<output>` tag implemented in ruby.

## Parameters

This component can take up to 5 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `<output>` should have.

#### # class (optional)
Expects a string with all classes the `<output>` should have.

#### # name (optional)
Specifies a name for the `<output>` element

#### # for (optional)
Specifies the relationship between the result of the calculation, and the elements used in the calculation

#### # form (optional)
Specifies one or more forms the `<output>` element belongs to

## Example 1:

```ruby
output name: 'x', for: 'a b', text: ''
```

returns

```html
<output for="a b" name="x"></output>
```

## Example 2:

```ruby
output id: 'my-id', class: 'my-class', name: 'x', for: 'a b', form: 'form_id' do
  plain 'All attributes'
end
```

returns

```html
<output for="a b" form="form_id" id="my-id" name="x" class="my-class">
  All attributes
</output>
```
