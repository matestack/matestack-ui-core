# Matestack Core Component: Video

The HTML `video` tag, implemented in Ruby.

## Parameters
The video component takes mandatory path and type arguments and can take a number of optional configuration params.

#### autoplay (optional)
Expects a boolean and specifies whether the video should start playing as soon as it is ready.

#### controls (optional)
Expects a boolean and specifies whether the video controls (play/pause button etc) should be displayed.

#### height (optional)
Expects an integer with the height of the video in px.

#### loop (optional)
Expects a boolean and specifies whether the video will start over again every time it is finished.

#### muted (optional)
Expects a boolean and specifies whether the audio output of the video should be muted.

#### path
Expects a string with the source to the video. It looks for the video in the `assets/videos` folder and uses the standard Rails asset pipeline.

#### type
Expects a string with the type to the video.

#### playsinline (optional)
Expects a boolean and specifies whether the video should be played inline on iOS Safari.

#### preload (optional)
Expects a string (`auto`, `metadata` or `none`) and specifies whether the whole video/only metadata/nothing should be loaded on pageload. Default (if not specified) depends on the client's browser.

#### width (optional)
Expects an integer with the width of the video in px.

## Examples

### Example 1: Basic usage

```ruby
video path: 'corgi.mp4', type: "mp4", width: 500, height: 300
```

returns

```HTML
<video height='300' width='500'>
  <source src='/assets/corgi-[...].mp4' type='video/mp4'>
  Your browser does not support the video tag.
</video>
```
