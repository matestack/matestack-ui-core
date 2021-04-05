# Abbr

The HTML `<abbr>` tag, implemented in Ruby.

## Parameters

This component expects 1 required param and various optional configuration params and can either yield content or display what gets passed to the `text` configuration param.

### Title - required

Expects a string with the meaning of the abbreviation contained within the tag.

### Text \(optional\)

Expects a string which will be displayed as the content inside the `<abbr>` tag. If this is not passed, a block must be passed instead.

### HMTL attributes \(optional\)

This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1 - render options\[:text\] param

```ruby
abbr title: 'Hypertext Markup Language', text: 'HTML'
```

returns

```markup
<abbr title="Hypertext Markup Language">HTML</abbr>
```

### Example 2 - yield a given block

```ruby
abbr title: 'Cascading Style Sheets' do
  span text: 'CSS'
end
```

returns

```markup
<abbr title="Cascading Style Sheets"><span>CSS</span></abbr>
```

