# matestack core component: s

Show [specs](/spec/usage/components/s_spec.rb)

The HTML `<s>` tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the s tag should have.

#### # class (optional)
Expects a string with all classes the s tag should have.

#### # text (optional)
Expects a string with the text that s go into the `<s>` tag.

## Example 1
Specifying the text directly

```ruby
  s id: "foo", class: "bar" text: "Hello World"
```

returns

```html
<s id="foo" class="bar">Hello World</s>
```

## Example 2
Rendering a content block between the `<s>` tags

```ruby
s id: "foo", class: "bar" do
  plain "Hello World"
end
```

returns

```html
<s id="foo" class="bar">Hello World</s>
```
