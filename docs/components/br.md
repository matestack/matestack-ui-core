# basemate core component: Br

Show [specs](../../spec/usage/components/br_spec.rb)

The HTML `<br>` tag implemented in ruby.

## Parameters

This component can take 1 optional configuration param.

#### # times (optional)
The number of times you want to repeat the spacing.

## Example 1
Using the `<br>` tag once

```ruby
heading text: "foo"
br
heading text: "bar"
```

returns

```html
<h1>foo</h1>
<br>
<h1>bar</h1>
```

## Example 2
Using the `<br>` tag a couple of times

```ruby
heading text: "foo"
br times: 3
heading text: "bar"
```

returns

```html
<h1>foo</h1>
<br>
<br>
<br>
<h1>bar</h1>
```
