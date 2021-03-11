# Youtube

A youtube video, embedded into an `iFrame` HTML tag.

## Parameters

The video tag takes a mandatory _youtube id_ as argument and can take a number of optional configuration params.

### youtube\_id

Expects a string with the id to the youtube video you want to embed.

### id, class \(optional\)

Like most of the core components, you can give a video an id and a class.

### height

Expects an integer with the height of the iFrame in px.

### width

Expects an integer with the width of the iFrame in px.

### no\_controls \(optional\)

Expects a boolean. If set to true, no controls will be displayed with the embedded youtube video.

### privacy\_mode \(optional\)

Expects a boolean. If set to true, the video gets loaded from 'www.youtube-nocookie.com' instead of the default 'www.youtube.com'.

### start\_at \(optional\)

Expects an integer that indicates at what second the video should start.

## Example 1

```ruby
youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I'
```

gets rendered into

```markup
<iframe allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen='' frameborder='0' height='360' src='https://www.youtube.com/embed/OY5AeGhgK7I' width='360'></iframe>
```

## Example 2

```ruby
youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I', start_at: 30, no_controls: true
youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I', start_at: 30, privacy_mode: true
```

gets rendered into

```markup
<iframe allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen='' frameborder='0' height='360' src='https://www.youtube.com/embed/OY5AeGhgK7I?controls=0&amp;start=30' width='360'></iframe>
<iframe allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen='' frameborder='0' height='360' src='https://www.youtube-nocookie.com/embed/OY5AeGhgK7I?start=30' width='360'></iframe>
```

