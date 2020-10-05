# Matestack Core Component: Details

The HTML `<details>` and `<summary>` tags, implemented in Ruby.

## Parameters
The `<summary >`tag either yields content or displays what gets passed to the `text` configuration param. Both `<details>` and `<summary>` tag accept all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Render options[:text] param in `<summary>`

```ruby
details id: 'foo', class: 'bar' do
  summary text: 'Greetings'
  plain "Hello World!" # optional content
end
```

```html
<details id="foo" class="bar">
  <summary>Greetings</summary>
  Hello World!
</details>
```

### Example 2: Yield a given block in `<summary>`

```ruby
details id: 'foo', class: 'bar' do
  summary do
    plain 'Greetings'
  end
  paragraph text: 'Hello World!'
end
```

```html
<details id="foo" class="bar">
  <summary>Greetings</summary>
  <p>Hello World!</p>
</details>
```

### Example 3: Using `<detail>` without `<summary>`

```ruby
details id: 'foo' do
  plain "Hello World!"
end
```

```html
<details id="foo">
  Hello World!
</details>
```
