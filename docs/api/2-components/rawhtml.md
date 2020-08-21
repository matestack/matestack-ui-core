# Matestack Core Component: Rawhtml

This element simply renders the value of a variable (or simple a string) wherever you want it **without escaping HTML**.

Only use this if you are sure that you have full control over the input to this function/no malicious code can find its way inside.

## Parameters

This component expects one parameter.

## Example 1

Rendering some HTML.

```ruby

def response
  rawhtml <<~HTML
  <h1>Hello World</h1>
  <script>alert('Really Hello!')</script>
  HTML
end

```

returns

```html
<h1>Hello World</h1>
<script>alert('Really Hello!')</script>
```
