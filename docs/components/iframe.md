# matestack core component: Iframe

Show [specs](/spec/usage/components/iframe_spec.rb)

The HTML iframe tag implemented in ruby.

## Parameters

This component can take 3 configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the `iframe` should have.

#### # class (optional)
Expects a string with all classes the `iframe` should have for styling purpose.


#### # src
Specifies the address of the document to embed in the `iframe` tag.

## Example 1: Yield a given block

```ruby
iframe id: "foo", class: "bar", src="https://www.demopage.com" do
  plain 'The browser does not support iframe.'
end
```

returns

```html
<iframe id="foo" class="bar" src="https://www.demopage.com">
  The browser does not support iframe.
</iframe>
```

## Example 2: Render options[:text] param

```ruby
iframe id: "foo", class: "bar", src="https://www.demopage.com", text: 'The browser does not support iframe.'
```

returns

```html
<iframe id="foo" class="bar" src="https://www.demopage.com">
  The browser does not support iframe.
</iframe>
```

