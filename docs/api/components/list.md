# Matestack Core Component: Lists

Feel free to check out the [component specs](/spec/usage/components/list_spec.rb).

Use lists to implement `<ol>`, `<ul>` and `<li>`-tags.

## Parameters

Both list definitions (`<ol>` and `<ul>`) and list elements (`<li>`) can take 2 optional configuration params. List elements (`<li>`) can also take a third param, text input.

#### # id (optional)
Expects a string with all ids the element should have.

#### # class (optional)
Expects a string with all classes the element should have.

#### # text (optional)
Expects a string which will be rendered between the opening and closing `<li>`-tag

## Example 1
Implementing a simple ordered list.

```ruby
ol id: "foo" do
  li text: "bar"
end
```

returns

```html
<ol id="foo">
  <li>bar</li>
</ol>
```

## Example 2
Implementing a simple unordered list that shows both options you have to pass arguments to list elements

```ruby
@base = mate
# ...
ul do
  li text: "foo"
  li do
    plain "bar"
  end
  li do
    plain @base
  end
end
```

returns

```html
<ul>
  <li>foo</li>
  <li>bar</li>
  <li>mate</li>
</ul>
```

## Example 3
The real beauty comes into play when things get a little more complicated

```ruby
@users = ["Jonas", "Pascal", "Chris"]
# ...
ul do
  @users.each do |user|
    li text: user
  end
end
```

returns

```html
<ul>
  <li>Jonas</li>
  <li>Pascal</li>
  <li>Chris</li>
</ul>
```
