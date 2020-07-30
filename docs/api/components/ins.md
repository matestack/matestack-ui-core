# matestack core component: Ins

Show [specs](/spec/usage/components/ins_spec.rb)

The HTML ins tag implemented in Ruby.

## Parameters

This component can take 4 optional configuration params and either yield content or display what gets passed to the `text` configuration param.

#### # id (optional)
Expects a string with all ids the ins tag should have.

#### # class (optional)
Expects a string with all classes the ins tag should have.

#### # cite (optional)
Expects a string with a URL to a document that explains the reason why the text was inserted/changed.

#### # datetime (optional)
Expects a string which specifies the date and time of when the text was inserted/changed.

## Example 1: Yield a given block

```ruby
ins id: "foo", class: "bar", cite: "example.html", datetime: "2008-05-25T17:25:00Z" do
  plain 'Inserted text' # optional content
end
```

returns

```html
<ins id="foo" class="bar" cite="example.html" datetime="2008-05-25T17:25:00Z">Inserted text</ins>
```

## Example 2: Render options[:text] param

```ruby
ins id: "foo", class: "bar", cite: "example.html", datetime: "2008-05-25T17:25:00Z", text: 'Inserted text'
```

returns

```html
<ins id="foo" class="bar" cite="example.html" datetime="2008-05-25T17:25:00Z">Inserted text</ins>
```