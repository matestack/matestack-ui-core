# matestack core component: abbr

Show [specs](../../spec/usage/components/abbr_spec.rb)

The HTML `abbr` tag implemented in ruby.

## Parameters

This component expects 1 required param, 2 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # title
Expects a string with the meaning of the abbreviation contained within the tag.

#### # id - optional
Expects a string with all ids the `abbr` should have.

#### # class - optional
Expects a string with all classes the `abbr` should have.

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
  span do
    plain 'CSS'
  end
end
```

returns

```html
<abbr title="Cascading Style Sheets">CSS</abbr>
```
