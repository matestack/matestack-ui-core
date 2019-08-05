# matestack core component: Table

Show [specs](../../spec/usage/components/table_spec.rb)

Use tables to implement `<table>`, `<tr>`, `<th>`, `<td>`, `<thead>`, `<tbody>` and `<tfoot>` tags.

## Parameters

`<table>`, `<tr>`, `<thead>`, `<tbody>` and `<tfoot>` can take 2 optional configuration params.
`<th>` and `<td>` tags can also take a third param, text input.

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
  thead do
    tr class: "bar" do
      th text: "First"
      th text: "Matestack"
      th text: "Table"
    end
  end
  tbody do
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
  tfoot do
    tr do
      td text: "Eins"
      td text: "Zwei"
      td text: "Drei"
    end
  end
end
```

returns

```html
<table class="foo">
  <tr class="bar">
    <th>First</th>
    <th>Matestack</th>
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

## Example 3

`thead`, `tbody` and `tfoot` are optional containers for any number of `tr`s. If none are specified, `tbody` will be used to contain all `tr` components. `thead` is typically used for the head of the table, and `tfoot` for any table footer, where applicable, such as a sum or count.

```ruby
table do
  thead do
    tr do
      th text: "Product"
      th text: "Price"
    end
  end
  # tbody is unnecessary, since it has no class or id and will be added automatically
  # tbody do
    tr do
      td text: "Apples"
      td text: "3.50"
    end
    tr do
      td text: "Oranges"
      td text: "2.75"
    end
    tr do
      td text: "Bananas"
      td text: "4.99"
    end
  # end
  tfoot do
    tr do
      td text: "Total:"
      td text: "11.24"
    end
  end
end
```

returns

```html
<table>
  <thead>
    <tr>
      <th>Product</th>
      <th>Price</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Apples</td>
      <td>3.50</td>
    </tr>
    <tr>
      <td>Oranges</td>
      <td>2.75</td>
    </tr>
    <tr>
      <td>Bananas</td>
      <td>4.99</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td>Total:</td>
      <td>11.24</td>
    </tr>
  </tfoot>
</table>
```
