# matestack core component: Fieldset

Show [specs](/spec/usage/components/fieldset_spec.rb)

Use Fieldset to group several `<input>` and `<label>` tags.


## Parameters

`<fieldset>` can take two optional configuration params and optional content.


### Optional configuration

#### id (optional)

Expects a string with all ids the details tag should have.

#### class (optional)

Expects a string with all classes the details tag should have.

#### Disabled (optional)

Set `disabled` attribute on `<fieldset>` to disable all controls inside the `<fieldset>`

## Example 1

```ruby
 fieldset do
    legend text: 'Your Inputs for Personal details'
    label text: 'Personal Detail'
    input
  end
```

```html
<fieldset>
  <legend>Your Inputs for Personal details</legend>
  <label>Personal Detail</label>
  <input>
</fieldset>
```

## Example 2

```ruby
fieldset id: 'foo', class: 'bar' do
  legend id: 'baz', text: 'Your Inputs for Personal details'
  label text: 'Personal Detail'
  input 
end
```

```html
<fieldset id="foo" class="bar">
  <legend id="baz">Your Inputs for Personal details</legend>
  <label>Personal Detail</label>
  <input>
</fieldset>
```


### Example 3

**With Disabled Attribute**

```ruby 
fieldset disabled: true do
  legend text: 'input legend'
  input
end
```

```html 
<fieldset disabled="disabled">
  <legend>input legend</legend>
  <input>
</fieldset>
```

