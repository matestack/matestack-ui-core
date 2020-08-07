# Matestack Core Component: Link

Feel free to check out the [component specs](/spec/usage/components/link_spec.rb).

This component is used to either navigate within your matestack application or to send requests to outside URLs.

## Parameters

This component creates an `<a>`-tag and expects a mandatory path input and optional options parameters.

#### # path
If the path input is a **string** it creates a link to the outside web.

If the path input is a **symbol** (e.g. :root_path) it creates a route **within** your Rails application. See example 4 for further details.

#### # text (optional)
The text that gets wrapped by the `<a>`-tag. If no text is given the link component looks for further arguments within itself (see examples below).

#### # id (optional)
Expects a string with all ids `<a>`-tag should have.

#### # class (optional)
Expects a string with all classes `<a>`-tag should have.

#### # method (optional, default is get)
The HTTP request method the link should implement.

#### # target (optional, default is nil)
Specify where to open the linked document.

#### # title (optional)
Specify a title for the link (shown on mouseover).

## Example 1
This example renders a simple link within a `<div`-tag

```ruby
div id: "foo", class: "bar" do
  link path: "https://matestack.org", text: "Here"
end
```

and returns

```html
<div id="foo" class="bar">
  <a href="https://matestack.org">Here</a>
</div>
```

## Example 2
This example renders a link without a specific link-text, so it wraps the rest of its content.

```ruby
div id: "foo", class: "bar" do
  link path: "https://matestack.org", title: "The matestack website" do
    plain "Here"
  end
end
```

returns

```html
<div id="foo" class="bar" title="The matestack website">
  <a href="https://matestack.org">Here</a>
</div>
```

## Example 3
This example renders a link around a div and the link opens in a new tab.

```ruby
div id: "foo", class: "bar" do
  link path: "https://matestack.org", target: "_blank" do
    div do
      plain "Here"
    end
  end
end
```

returns

```html
<div id="foo" class="bar">
  <a target="_blank" href="https://matestack.org">
    <div>Here</div>
  </a>
</div>
```

## Example 4
This example renders a link with a get request to the **root_path** within your Rails application.

```ruby
div id: "foo", class: "bar" do
  link path: :root_path do
    plain "Here"
  end
end
```

returns

```html
<div id="foo" class="bar">
  <a href="/">
    Here
  </a>
</div>
```

## Example 5 - path from symbol
This example renders a link with a get request to any within your Rails application. In case you want to switch between pages within one specific matestack app, using the `transition` component probably is a better idea though!

```ruby
div id: "foo", class: "bar" do
  link path: :inline_edit_path, text: 'Click to edit'
end
```

returns

```html
<div id="foo" class="bar">
  <a href="/inline_edit">Click to edit</a>
</div>
```

## Example 6 - path from symbol with params
You can also dynamically create `paths` from symbols and params, as displayed below:

```ruby
div id: "foo", class: "bar" do
  link path: :single_endpoint_path, params: {number: 1}, text: 'Call API endpoint 1'
end
```

returns

```html
<div id="foo" class="bar">
  <a href="/api/single_endpoint/1">Call API endpoint 1</a>
</div>
```
