# matestack core component: Param

Show [specs](/spec/usage/components/param_spec.rb)

The HTML `<param>` tag implemented in ruby.

## Parameters

This component can take 4 optional configuration params.

#### # id (optional)
Expects a string with all ids the `<param>` should have.

#### # class (optional)
Expects a string with all classes the `<param>` should have.

#### # name (optional)
Specifies the name of a parameter.

#### # value (optional)
Specifies the value of the parameter


## Example 1:

```ruby
param name: 'autoplay', value: 'true'
```

returns

```html
<param name="autoplay" value="true">
```

## Example 2:

```ruby
param name: 'autoplay', value: 'true', id: 'my-id', class: 'my-class'
```

returns

```html
<param id="my-id" name="autoplay" value="true" class="my-class">
```
