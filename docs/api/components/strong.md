# matestack core component: Strong

Show [specs](/spec/usage/components/strong_spec.rb)

The HTML `<strong>` tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the strong tag should have.

#### # class (optional)
Expects a string with all classes the strong tag should have.

#### # text (optional)
Expects a string with the text that should go into the `<strong>` tag.

## Example 1
Specifying the text directly

```ruby
  strong id: "foo", class: "bar" text: "Hello World"
```

returns

```html
<strong id="foo" class="bar">Hello World</strong>
```

## Example 2
Rendering a content block between the `<strong>` tags

```ruby
strong id: "foo", class: "bar" do
  plain "Hello World"
end
```

returns

```html
<strong id="foo" class="bar">Hello World</strong>
```
