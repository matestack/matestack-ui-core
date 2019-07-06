# matestack core component: Details

Show [specs](../../spec/usage/components/details_summary_spec.rb)

Use details to implement `<details>` and `<summary>` tags.


## Parameters

`<details>` and `<summary>` can take two optional configuration params and optional content.


### Optional configuration

#### id (optional)

Expects a string with all ids the details tag should have.

#### class (optional)

Expects a string with all classes the details tag should have.


## Example 1

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

## Example 2

```ruby
details id: 'foo', class: 'bar' do
  summary id: 'baz', text: 'Greetings'
  pg text: 'Hello World!'
end
```

```html
  <details id="foo" class="bar">
      <summary id="baz">Greetings</summary>
      <p>Hello World!</p>
    </details>
```

## Example 3 (Without Summary)

```ruby
  details id: 'foo' do
    plan "Hello World!"
  end
```

```html
  <details id="foo">
    Hello World!
  </details>
```
