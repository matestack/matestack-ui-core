# Matestack Core Component: Img

The HTML img tag, implemented in Ruby.

## Parameters

The image takes a mandatory path argument and can take 4 optional configuration params.

#### path

Expects a string with the source to the image.

By default it looks for the image in the assets/images folder and uses the standard Rails asset pipeline unless given an absolute path.

See examples below.

#### alt \(optional\)

Expects a string with the alt text the image should have.

#### height \(optional\)

Expects an integer with the height of the image in px.

#### usemap \(optional\)

Expects a string to specify the image as a client-side image-map.

#### width \(optional\)

Expects an integer with the width of the image in px.

## Examples

### Example 1: Use Sprockets \(Rails asset pipeline\) implicitly

If your image is located here: `app/assets/images/some_image.png`

```ruby
img path: "some_image.png"
```

### Example 2: Use Sprockets \(Rails asset pipeline\) explicitly

If your image is located here: `app/assets/images/some_image.png`

```ruby
img path: image_url('some_image.png')
```

### Example 3: Use Webpacker explicitly

If something like below is configured in your pack.js and your image is located here: `app/javascript/images/some_image.png`

`app/javascript/packs/application.js`

```javascript
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
```

```ruby
img path: asset_pack_url('media/images/some_image.png')
```

