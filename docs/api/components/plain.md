# Matestack Core Component: Plain

This component simply renders the value of a variable (or simply a string) wherever you want it, **escaping HTML tags** (`<` becomes `&lt;` etc.).

Feel free to check out the [component specs](/spec/usage/components/plain_spec.rb) and see the [examples](#examples) below.

## Parameters
This component expects one parameter.

## Examples

### Example 1: Rendering a string into a `<div>` tag.

```ruby

def response
  components {
    div id: "foo", class: "bar" do
      plain "Hello World"
    end
  }
end

```

returns

```html
<div id="foo" class="bar">
  Hello World
</div>
```
### Example 2: Render a variable into a `<div>` tag.

```ruby

@hello = "World"
# ...
def response
  components {
    div id: "foo", class: "bar" do
      plain @hello
    end
  }
end

```

returns

```html
<div id="foo" class="bar">
  World
</div>
```
