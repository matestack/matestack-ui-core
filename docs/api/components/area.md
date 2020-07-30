# matestack core component: Area

Tested within the [map specs](/spec/usage/components/map_spec.rb).

The HTML `<area>` tag implemented in Ruby.

## Parameters
This component takes up to 10 optional configuration params. It is meant to be used within the `<map>` component.

#### # alt (optional)
Expects a string that specifies an alternate text for the `<area>`. Required if the href attribute is present.

#### # coords (optional)
Expects an array of integers that define the `<area>`'s coordinates. For more details, see the [official documentation](https://www.w3schools.com/tags/att_area_coords.asp).

#### # download (optional)
Expects a string to specify the target that will be downloaded when a user clicks on the hyperlink.

#### # href (optional)
Expects a string to specify the hyperlink target for the area.

#### # hreflang (optional)
Expects a string to specify the language of the target URL.

#### # media (optional)
Expects a string to specify what media/device the target URL is optimized for.

#### # rel (optional)
Expects a string to specify the relationship between the current document and the target URL.

#### # shape (optional)
Expects a string to specify the shape of the area: Default, rect, circle, poly.

#### # target (optional)
Expects a string to specify where to open the target URL.

#### # type (optional)
Expects a string to specify the media type of the target URL.

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
