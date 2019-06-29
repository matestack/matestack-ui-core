# matestack core component: Caption

Show [specs](../../spec/usage/components/caption_spec.rb)

The HTML `<caption>` tag implemented in ruby. According to the [W3C specification](https://www.w3schools.com/tags/tag_caption.asp), it defines a table caption, it must be inserted directly after the `<table>` tag, and there should only be one caption per table.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the caption should have.

#### # class (optional)
Expects a string with all classes the caption should have.

#### # text (optional)
Expects a string with the text that should go inside the `<caption>` tag.

## Example 1

Specifying the text directly

```ruby
table do
  caption text: "table caption"
  # table contents
end
```

returns

```html
<table>
  <caption>table caption</caption>
  <!-- table contents -->
</table>
```

## Example 2

Rendering a content block between the `<caption>` tags

```ruby
table id: 'foo', class: 'bar' do
  caption do
    plain "table caption"
  end
end
```

returns

```html
<table id="foo" class="bar">
  <caption>table caption</caption>
</table>
```

## Example 3

Rendering a `<span>` tag inside `<caption>` tags

```ruby
table do
  caption do
    plain "Hello"
    span do
      plain "table contents"
    end
  end
end
```

returns

```html
<table>
  <caption>
    Hello <span>table contents</span>
  </caption>
</table>
```
