# basemate core component: Heading

The HTML heading tag implemented in ruby.

## Parameters

This component can take 4 optional configuration params and optional content.

#### # size
Expects an integer between 1 and 6 to set the heading size. Other incoming values will be set to h1 by default.

#### # id
Expects a string with all ids the heading should have.

#### # class
Expects a string with all classes the heading should have.

#### # text
Expects a ruby string with the text the heading should show.

## Example

```ruby
heading size: 3, id: "foo", class: "bar", text: "Hello World" do
# Instead of the text parameter you can use
#  plain 'Hello World' as content
# with the same result
end
```

returns

```html
<h3 id="foo" class="bar">
  Hello World
</h3>
```
