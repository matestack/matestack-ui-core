# matestack core component: Button

Show [specs](../../spec/usage/components/button_spec.rb)

The HTML `<button>` tag implemented in Ruby.

## Parameters

This component can take 4 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the button should have.

#### # class (optional)
Expects a string with all classes the button should have.

#### # text (optional)
Expects a string with the text that should go inside the `<button>` tag.

#### # disabled (optional)
Expects a boolean to specify a disabled `<button>` tag.

## Example 1

Specifying the button text directly

```ruby
button text: 'Click me'
```

returns

```html
<button>Click me</button>
```

## Example 2

Rendering a content block inside the `<button>` tag:

```ruby
button id: 'foo', class: 'bar' do
  plain "Click me"
end
```

returns

```html
<button id="foo" class="bar">Click me</button>
```

## Example 3

By passing a boolean via `disabled: true`, you define disabled buttons. Passing nothing or explicitly defining `disabled: false` return the same result:

```ruby
button disabled: true, text: 'You can not click me'
button disabled: false, text: 'You can click me'
button text: 'You can click me too'
```

returns

```html
<button disabled="disabled">You can not click me</button>
<button>You can click me</button>
<button>You can click me too</button>
```
