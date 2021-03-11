# Option

The HTML `<option>` tag, implemented in Ruby.

## Parameters

This component can take 7 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

### id \(optional\)

Expects a string with all ids the `<option>` should have.

### class \(optional\)

Expects a string with all classes the `<option>` should have.

### disabled \(optional\)

Specifies that the `<option>` should be disabled.

### label \(optional\)

Specifies a shorter label for the `<option>`.

### text \(optional\)

Specifies the text the `<option>` should contain.

### selected \(optional\)

Specifies that the `<option>` should be pre-selected when the page loads.

### value \(optional\)

Specifies the value to be sent to a server.

## Example 1: Render `options[:text]` param

```ruby
option text: 'Option 1'
```

returns

```markup
<option>Option 1</option>
```

## Example 2: Render `options[:label]` param

```ruby
option label: 'Option 2'
```

returns

```markup
<option label="Option 2"></option>
```

## Example 3: Render with more attributes

```ruby
option disabled: true, label: 'Option 3', selected: true, value: '3'
```

returns

```markup
<option disabled="disabled" label="Option 3" selected="selected" value="3"></option>
```

## Example 4: Yield a given block

```ruby
option id: 'foo', class: 'bar' do
  plain 'Option 4'
end
```

returns

```markup
<option id="foo" class="bar">
  Option 4
</option>
```

