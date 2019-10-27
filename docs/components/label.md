# matestack core component: Label

Show [specs](/spec/usage/components/label_spec.rb)


The HTML label tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the div should have.

#### # class (optional)
Expects a string with all classes the div should have.

#### # for (optional)
Expects a string that binds the label to a given form element

## Example

```ruby
label id: "foo", class: "bar", for: 'input_id' do
  plain 'Label For Element' # optional content
end
```

returns

```html
<label for="input_id" id="foo" class="bar">
  Label For Element
</label>
```

