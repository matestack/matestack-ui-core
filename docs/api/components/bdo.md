# matestack core component: Bdo

Show [specs](/spec/usage/components/bdo_spec.rb)

The HTML `<bdo>` tag implemented in ruby.

## Parameters

This component takes 1 required param and 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # dir (required)
Expects a string with either 'ltr' or 'rtl' to specify text direction inside the `<bdo>` element.

#### # id (optional)
Expects a string with all ids the `<bdo>` should have.

#### # class (optional)
Expects a string with all classes the `<bdo>` should have.

## Example 1: Yield a given block

```ruby
bdo id: 'foo', class: 'bar', dir: 'ltr' do
  plain 'This text will go left-to-right.' # optional content
end
```

returns

```html
<bdo id="foo" class="bar" dir="ltr">
  This text will go left-to-right.
</bdo>
```

## Example 2: Render `options[:text]` param

```ruby
bdo id: 'foo', class: 'bar', dir: 'rtl', text: 'This text will go right-to-left.'
```

returns

```html
<bdo id="foo" class="bar" dir="rtl">
  This text will go right-to-left.
</bdo>
