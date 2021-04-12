# HTML Rendering

Matestack’s rendering mechanism takes care of converting Ruby into HTML:

```ruby
div class: "card shadow-sm border-0 bg-light", foo: "bar" do
  img path: "...", class: "w-100"
  div class: "card-body" do
    h5 "foo", class: "card-title"
    paragraph "bar", class: "card-text"
  end
end
```

will be rendered to:

```markup
<div class="card shadow-sm border-0 bg-light" foo="bar">
  <img src="..." class="w-100">
  <div class="card-body">
    <h5 class="card-title">foo</h5>
    <p class="card-text">bar</p>
  </div>
</div>
```

That's working because `matestack-ui-core` defines all kind of Ruby methods targeting Rails ActionView `tag` helper, rendering the desired HTML tag and content as a String. 

Following tags are supported:

## Supported HTML Tags

### Void Tags

These tags by definition do not allow an inner HTML and therefore do not take an block but all kinds of tag attributes, e.g.:

```ruby
# ...
hr class: "some-class"
# ...
```

* area 
* base 
* br 
* col 
* hr 
* img \| _you can use `src` or `path` in order to reference the url to the image_
* input 
* link 
* meta 
* param 
* command 
* keygen 
* source

### Tags

The following tags take content via a block OR first \(non-hash\) argument and all kind of tag attributes, e.g.: 

```ruby
# define inner HTML via a block
span class: "some-class" do
  plain "foo"
end
# OR: define inner HTML via a simple first non-hash argument 
span "foo", class: "some-class"
# ...
```

* a \| _you can use `href` or `path` in order to reference the url of the link_
* abbr
* acronym
* address
* applet
* article
* aside
* audio
* b
* base
* basefont
* bdi
* bdo
* big
* blockquote
* body
* button
* canvas
* caption
* center
* cite
* code
* col
* colgroup
* data
* datalist
* dd
* del
* details
* dfn
* dialog
* dir
* div
* dl
* dt
* em
* embed
* fieldset
* figcaption
* figure
* font
* footer
* form
* frame
* frameset
* h1 \| _also available via `heading size: 1`_
* h2 \| _also available via `heading size: 2`_
* h3 \| _also available via `heading size: 3`_
* h4 \| _also available via `heading size: 4`_
* h5 \| _also available via `heading size: 5`_
* h6 \| _also available via `heading size: 6`_
* head
* header
* html
* i
* iframe
* ins
* kbd
* label
* legend
* li
* main
* map
* mark
* meter
* nav
* noframes
* noscript
* object
* ol
* optgroup
* option
* output
* paragraph \| _p is not working as it's an alias for puts in Ruby core_
* picture
* pre
* progress
* q
* rp
* rt
* ruby
* s
* samp
* script
* section
* select
* small
* span
* strike
* strong
* style
* sub
* summary
* sup
* svg
* table
* tbody
* td
* template
* textarea
* tfoot
* th
* thead
* time
* title
* tr
* track
* tt
* u
* ul
* var
* video
* wbr

## Text Rendering

In order to render plain text, do:

```ruby
#...
plain "hello world!"
# "hello world!" alone would not be rendered!
#...
```

## Tag/Data Attributes

Matestack's rendering mechanism automatically renders all given options as tag attributes. For convenience, data attributes can be passend in within a data hash:

```ruby
div class: "foo", id: "bar", hello: "world", data: { foo: "bar" } do
  #...
end
```

```markup
<div class="foo" id="bar" hello="world" data-foo="bar">
  <!-- ... -->
</div>
```

## Custom HTML Tags

If you want to use HTML tags which are not supported by Matestack's rendering mechanism by default, you can call ActionView's `tag` helper manually: 

[https://apidock.com/rails/ActionView/Helpers/TagHelper/tag](https://apidock.com/rails/ActionView/Helpers/TagHelper/tag)

```ruby
plain tag.xyz("foo")
```

will render:

```markup
<xyz>foo</xyz>
```

