# matestack core component: Input

Show [specs](/spec/usage/components/input_spec.rb)

The HTML textarea tag implemented in ruby.

## Parameters

This component can take all w3c specified html attributes as parameters and a text parameter. All parameters are optional.

#### # text (optional)
Expects a string specifying the content of the textarea.

## Example

```ruby
textarea id: "foo", class: "bar", cols: 2, maxlength: 20, text: 'Hello World!'
```

returns

```html
<textarea type="text" id="foo" class="bar" cols="2" maxlength="20">Hello World!</textarea>
```