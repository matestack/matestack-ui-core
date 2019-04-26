# basemate core component: Img

Show [specs](../../spec/usage/components/icon_spec.rb)

The HTML img tag implemented in ruby.

## Parameters

The image takes a mandatory path argument and can take 3 optional configuration params.

#### # path
Expects a string with the source to the image. It looks for the image in the assets/images folder and uses the standard Rails asset pipeline.

#### # height (optional)
Expects an integer with the height of the image in px.

#### # width (optional)
Expects an integer with the width of the image in px.

#### # alt (optional)
Expects a string with the alt text the image should have.
