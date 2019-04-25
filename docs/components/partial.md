# basemate core component: Partial

This element renders a (predefined) partial into any other element.

## Parameters

See below for implementation options.

## Example 1

Render a simple heading partial into a div tag.

```ruby
def response
  components {
    div id: "foo", class: "bar" do
      partial :another_section
    end
  }
end

def another_section
  partial {
    heading size: 4, text: "Hello World"
  }
end

```

returns

```html
<div id="foo" class="bar">
  <h4>Hello World</h4>
</div>
```

## Example 2

Render two headings into a div tag and pass their content as string.

```ruby
def response
  components {
    div id: "foo", class: "bar" do
      partial :another_section, "Hello"
      partial :another_section, "World"
    end
  }
end

def another_section param
  partial {
    heading size: 4, text: param
  }
end

```

returns

```html
<div id="foo" class="bar">
  <h4>Hello</h4>
  <h4>World</h4>
</div>
```

## Example 3

Render two headings into a div tag and pass their size and content as params.

```ruby
def response
  components {
    div id: "foo", class: "bar" do
      partial :another_section, 1, "Hello"
      partial :another_section, 2, "World"
    end
  }
end

def another_section size, content
  partial {
    heading size: size, text: content
  }
end

```

returns

```html
<div id="foo" class="bar">
  <h1>Hello</h1>
  <h2>World</h2>
</div>
```

## Example 4

Render a partial which contains another partial into a div tag.

```ruby
def response
  components {
    div id: "foo", class: "bar" do
      partial :first_partial, "Hello"
    end
  }
end

def first_partial content
  partial {
    heading size: 1, text: content
    partial :second_partial
  }
end

def second_partial
  partial {
    heading size: 2, text: "World"
  }
end

```

returns

```html
<div id="foo" class="bar">
  <h1>Hello</h1>
  <h2>World</h2>
</div>
```
