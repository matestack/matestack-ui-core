# matestack core component: Paragraph

Show [specs](../../spec/usage/components/paragraph_spec.rb)

The HTML `<p>` tag implemented in ruby. This is a workaround because the single `p` is a reserved keyword in Ruby (directly writes `obj.inspect` followed by a newline to the program’s standard output, e.g. `p foo` equals `puts foo.inspect`).

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the p should have.

#### # class (optional)
Expects a string with all classes the p should have.

#### # text (optional)
Expects a string with the text that should go into the `<p>` tag.

## Example 1
Specifying the text directly

```ruby
div id: "foo", class: "bar" do
  paragraph text: "Hello World"
end
```

returns

```html
<div id="foo" class="bar">
  <p>Hello World</p>
</div>
```

## Example 2
Rendering a content block between the `<p>` tags

```ruby
div id: "foo", class: "bar" do
  paragraph do
    plain "Hello World"
  end
end
```

returns

```html
<div id="foo" class="bar">
  <p>Hello World</p>
</div>
```

## Example 3
Rendering a `<span>` tag into `<p>` tags

```ruby
paragraph id: "foo", class: "bar" do
  span do
    plain "Hello World"
  end
end
```

returns

```html
<p id="foo" class="bar">
  <span>Hello World</span>
</p>
```
