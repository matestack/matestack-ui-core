# Matestack Core Component: Map

The HTML `<map>` tag, implemented in Ruby.

## Parameters
This component can take various optional configuration params and yields content. It is supposed to contain a number of `<area>` elements that define the clickable areas in the image map.

### Name - required
Specifies the name of this `<map>` tag.

### HMTL attributes (optional)
This component accepts all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) like `id` or `class`.

## Examples

### Example 1: Basic usage

```ruby
img path: 'matestack-logo.png', width: 500, height: 300, alt: "otherlogo",  usemap: "#newmap"

map name: 'newmap' do
  area shape: 'rect', coords: [0,0,100,100], href: 'first.htm', alt: 'First'
  area shape: 'rect', coords: [0,0,100,100], href: 'second.htm', alt: 'Second'
  area shape: 'rect', coords: [0,0,100,100], href: 'third.htm', alt: 'Third'
end
```

returns

```html
<img src="matestack-logo.png" alt="otherlogo" width="500" height="300" usemap="#newmap">

<map name="newmap">
   <area shape="rect" coords="0,0,100,100" href="first.htm" alt="First">
   <area shape="rect" coords="100,100,200,200" href="second.htm" alt="Second">
   <area shape="rect" coords="200,200,300,300" href="third.htm" alt="Third">
</map>
```
