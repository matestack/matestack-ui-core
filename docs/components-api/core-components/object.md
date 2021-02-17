# Object

The HTML `<object>` tag, implemented in Ruby.

## Parameters

This component can take 9 optional configuration params, but at least one of the `data` or `type` attribute **MUST** be defined.

### class \(optional\)

Expects a string with all classes the `<object>` should have.

### data \(optional\)

Expects a string that specifies the URL of the resource to be used by the `<object`.

### form \(optional\)

Expects a string that contains one or more _form\_id_-s to specify one or more forms the `<object>` belongs to.

### height \(optional\)

Expects a number to specify the height of the `<object>`.

### id \(optional\)

Expects a string with all ids the `<object>` should have.

### name \(optional\)

Expects a string that specifies a name for the `<object>`.

### type \(optional\)

Expects a string to specify the media type of data specified in the data attribute.

### usemap \(optional\)

Expects a string to specify the name of a client-side image map to be used with the `<object>`.

### width \(optional\)

Expects a number to specify the width of the `<object>`.

## Example 1

```ruby
object width: 400, height: 400, data: 'helloworld.swf'
```

returns

```markup
<object width="400" height="400" data="helloworld.swf"></object>
```

## Example 2

```ruby
object id: 'my-id', class: 'my-class', width: 400, height: 400, data: 'helloworld.swf'
```

returns

```markup
<object id="my-id" class="my-class" width="400" height="400" data="helloworld.swf"></object>
```

