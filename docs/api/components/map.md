# matestack core component: Map

Show [specs](/spec/usage/components/map_spec.rb)

The HTML `<map>` tag implemented in Ruby.

## Parameters
This component has a required `name` attribute and takes 2 optional configuration params. It contains a number of `<area>` elements that define the clickable areas in the image map.

#### # id (optional)
Expects a string with all ids the `<map>` should have.

#### # class (optional)
Expects a string with all classes the `<map>` should have.

#### # name
Specifies the name of a parameter.

## Example:

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
