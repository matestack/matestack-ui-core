# matestack core component: Template

Show [specs](/spec/usage/components/template_spec.rb)

The HTML `<template>` tag implemented in ruby.

## Parameters

This component can take 2 optional configuration params and yield content, either directly or through partials/custom components.

#### # id (optional)
Expects a string with all ids the `<template>` should have.

#### # class (optional)
Expects a string with all classes the `<template>` should have.

## Example 1: Yield a given block

```ruby
template id: 'foo', class: 'bar' do
  paragraph text: 'Template example 1' # optional content
end
```

returns

```html
<template id="foo" class="bar">
  <p>Template example 1</p>
</template>
```

## Example 2: Render `options[:text]` param

```ruby
template id: 'foo', class: 'bar' do
  partial :example_content
end

def example_content
  partial {
    paragraph text: 'I am part of a partial'
  }
end
```

returns

```html
<template id="foo" class="bar">
  <p>I am part of a partial</p>
</template>
