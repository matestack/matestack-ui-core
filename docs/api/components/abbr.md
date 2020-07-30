# matestack core component: abbr

Show [specs](../../spec/usage/components/abbr_spec.rb)

The HTML `abbr` tag implemented in ruby.

## Parameters

This component expects 1 required param, 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # title - required
Expects a string with the meaning of the abbreviation contained within the tag.

#### # id - optional
Expects a string with all ids the `abbr` should have.

#### # class - optional
Expects a string with all classes the `abbr` should have.

#### # text - optional
Expects a string which will be displayed as the content inside the `abbr`. If this is not passed, a block must be passed instead.

## Example 1 - render options[:text] param

```ruby
abbr title: 'Hypertext Markup Language', text: 'HTML'
```

returns

```html
<abbr title="Hypertext Markup Language">HTML</abbr>
```


## Example 2 - yield a given block

```ruby
abbr title: 'Cascading Style Sheets' do
  span text: 'CSS'
end
```

returns

```html
<abbr title="Cascading Style Sheets">CSS</abbr>
```
