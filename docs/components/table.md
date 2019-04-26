# basemate core component: Table

Show [specs](../../spec/usage/components/table_spec.rb)

Use tables to implement `<table>`, `<tr>`, `<th>` and `<td>`-tags.

## Parameters

`<table>`, `<tr>`, can take 2 optional configuration params.
`<th>` and `<td>`-tags can also take a third param, text input.

#### # id (optional)
Expects a string with all ids the element should have.

#### # class (optional)
Expects a string with all classes the element should have.

#### # text (optional)
Expects a string which will be rendered between the opening and closing `<th>` or `<td>`-tag

## Example 1
Implementing a simple, hard coded table.

```ruby
table class: "foo" do
  tr class: "bar" do
    th text: "First"
    th text: "Basemate"
    th text: "Table"
  end
  tr do
    td text: "One"
    td text: "Two"
    td text: "Three"
  end
  tr do
    td text: "Uno"
    td text: "Dos"
    td text: "Tres"
  end
end
```

returns

```html
<table class="foo">
  <tr class="bar">
    <th>First</th>
    <th>Basemate</th>
    <th>Table</th>
  </tr>
  <tr>
    <td>One</td>
    <td>Two</td>
    <td>Three</td>
  </tr>
  <tr>
    <td>Uno</td>
    <td>Dos</td>
    <td>Tres</td>
  </tr>
</table>
```

## Example 2
The real beauty comes into play when things get a little more complicated

```ruby
def prepare
  @users = ["Jonas", "Pascal", "Chris"]
  @numbers = ["One", "Two", "Three"]
  @numeros = ["Uno", "Dos", "Tres"]
end
# ...
table class: "foo" do
  tr class: "bar" do
    @users.each do |user|
      th text: user
    end
  end
  tr do
    @numbers.each do |number|
      td text: number
    end
  end
  tr do
    @numeros.each do |numero|
      td text: numero
    end
  end
  # you are still in pure Ruby, so feel free to do other stuff as well
  tr do
    td do
      plain "Do"
    end
    td text: "Custom"
    td do
      plain "Stuff"
    end
  end
end
```

returns

```html
<table class='foo'>
  <tr class='bar'>
    <th>Jonas</th>
    <th>Pascal</th>
    <th>Chris</th>
  </tr>
  <tr>
    <td>One</td>
    <td>Two</td>
    <td>Three</td>
  </tr>
  <tr>
    <td>Uno</td>
    <td>Dos</td>
    <td>Tres</td>
  </tr>
  <tr>
    <td>Do</td>
    <td>Custom</td>
    <td>Stuff</td>
  </tr>
</table>
```
