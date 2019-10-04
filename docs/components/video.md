# matestack core component: Video

Show [specs](/spec/usage/components/video_spec.rb)

The HTML video tag implemented in ruby.

## Parameters
The video tag takes a mandatory path argument and can take a number of optional configuration params.

#### # path
Expects a string with the source to the video. It looks for the video in the `assets/videos` folder and uses the standard Rails asset pipeline.

#### # id, class
Like most of the core components, you can give a video an id and a class.

#### # height (optional)
Expects an integer with the height of the video in px.

#### # width (optional)
Expects an integer with the width of the video in px.

#### # alt (optional)
Expects a string with the alt text the video should have.

#### # preload
Expects a string (`auto`, `metadata` or `none`) and specifies whether the whole video/only metadata/nothing should be loaded on pageload. Default (if not specified) depends on the client's browser.

#### # autoplay
Expects a boolean and specifies whether the video should start playing as soon as it is ready.

#### # muted
Expects a boolean and specifies whether the audio output of the video should be muted.

#### # playsinline
Expects a boolean and specifies whether the video should be played inline on iOS Safari.

#### # loop
Expects a boolean and specifies whether the video will start over again every time it is finished.

#### # controls
Expects a boolean and specifies whether the video controls (play/pause button etc) should be displayed.
