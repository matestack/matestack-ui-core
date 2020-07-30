# matestack core component: Img

Show [specs](/spec/usage/components/icon_spec.rb)

The HTML img tag implemented in ruby.

## Parameters

The image takes a mandatory path argument and can take 4 optional configuration params.

#### # alt (optional)
Expects a string with the alt text the image should have.

#### # height (optional)
Expects an integer with the height of the image in px.

#### # path
Expects a string with the source to the image. It looks for the image in the assets/images folder and uses the standard Rails asset pipeline.

#### # usemap (optional)
Expects a string to specify the image as a client-side image-map.

#### # width (optional)
Expects an integer with the width of the image in px.
