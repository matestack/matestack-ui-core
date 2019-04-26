# basemate core component: Pg

Show [specs](../../spec/usage/components/pg_spec.rb)

The HTML `<p>` tag implemented in ruby. This is a workaround because the single `p` is the short version of `puts` in ruby.

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
  pg text: "Hello World"
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
  pg do
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
pg id: "foo", class: "bar" do
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
