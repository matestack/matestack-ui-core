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
Expects a string that binds the label to a given form element (To match `id` of form element)

#### # form (optional)
Expects a string that specifies which form or forms the label belongs to.

## Example

```ruby
label id: "foo", class: "bar", for: 'input_id', form: 'form1' do
  plain 'Label For Element' # optional content
end

label id: 'foo', form: 'form1', text: "Label for form with id='form1'"

```

returns

```html
<label for="input_id" id="foo" class="bar">
  Label For Element
</label>

<label form="form1" id="foo">Label for form with id='form1'</label>

```

