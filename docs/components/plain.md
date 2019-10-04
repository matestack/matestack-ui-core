# matestack core component: Plain

Show [specs](/spec/usage/components/plain_spec.rb)

This element simply renders the value of a variable (or simple a string) wherever you want it.

## Parameters

This component expects one parameter.

## Example 1

Rendering a string into a div tag.

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
## Example

Render a variable into a div tag.

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
