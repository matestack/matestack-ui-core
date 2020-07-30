# matestack core component: Pre

Show [specs](/spec/usage/components/pre_spec.rb)

The HTML pre tag implemented in ruby.

## Parameters

This component can take 3 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the pre should have.

#### # class (optional)
Expects a string with all classes the pre should have.

#### # text (optional)
Expects a ruby string with the text the address tag should show.

## Example 1: Yield a given block

```ruby
pre id: "foo", class: "bar" do
  plain 'Hello World' # optional content
end
```

returns

```html
<pre id="foo" class="bar">
  Hello World
</pre>
```

## Example 2: Render options[:text] param

```ruby
pre id: "foo", class: "bar", text: 'Hello World'
```

returns

```html
<pre id="foo" class="bar">
  Hello World
</pre>
