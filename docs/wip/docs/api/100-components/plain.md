# Matestack Core Component: Plain

This component simply renders the value of a variable \(or simply a string\) wherever you want it, **escaping HTML tags** \(`<` becomes `&lt;` etc.\).

## Parameters

This component expects one parameter.

## Examples

### Example 1: Rendering a string into a `<div>` tag.

```ruby
div id: "foo", class: "bar" do
  plain "Hello World"
end
```

returns

```markup
<div id="foo" class="bar">
  Hello World
</div>
```

### Example 2: Render a variable into a `<div>` tag.

```ruby
@hello = "World"
# ...

div id: "foo", class: "bar" do
  plain @hello
end
```

returns

```markup
<div id="foo" class="bar">
  World
</div>
```

