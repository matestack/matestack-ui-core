# matestack core component: Code

Show [specs](/spec/usage/components/code_spec.rb)

The HTML `<code>` tag implemented in Ruby.

## Parameters

This component can take 3 optional configuration params and optional content.

#### # id (optional)
Expects a string with all ids the `<code>` tag should have.

#### # class (optional)
Expects a string with all classes the `<code>` tag should have.

#### # text (optional)
Expects a string with the text that should go into the `<code>` tag.

## Example 1
Rendering content into the `code` component

```ruby
code id: "foo", class: "bar" do
  plain 'puts "Hello Mate One"'
end
```

returns

```html
<code id="foo" class="bar">
  puts "Hello Mate One"
</code>
```

## Example 2
Passing content to the `text` param

```ruby
code id: "foo", class: "bar", text: 'puts "Hello Mate Two"'
```

returns

```html
<code id="foo" class="bar">
  puts "Hello Mate Two"
</code>
```
