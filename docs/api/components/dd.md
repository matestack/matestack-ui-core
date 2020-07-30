# matestack core component: Dd

Show [specs](/spec/usage/components/dd_spec.rb)

The HTML dd tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `dd` should have.

#### # class (optional)
Expects a string with all classes the `dd` should have.

## Example 1: Yield a given block

```ruby
dd id: "foo", class: "bar" do
  plain 'Hello World'
end
```

returns

```html
<dd id="foo" class="bar">
  Hello World
</dd>
```

## Example 2: Render options[:text] param

```ruby
dd id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<dd id="foo" class="bar">
  Hello World
</dd>
```

