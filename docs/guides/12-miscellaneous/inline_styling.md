# Inline styling of Matestack components

## General approach

Matestack components can easily be styled through the `attributes` parameter. In a growing application, you will most probably work with a (S)CSS framework/library and often style your pages and components through `id`s and `classes`. Inline styles allow for dynamic styling and can come in handy in certain use cases - as shown below:

```ruby
# ...

def prepare
  @colors = ['green', 'blue', 'red']
end

def response
  @colors.each do |color|
    paragraph attributes: { style: "color: #{color};" }, text: "I will be displayed as #{color} text."
  end
end

# ...
```
## Accessing videos and images with inline styling

For now, we have to resort to an `ActionController` helper in order to work with our assets. See a working example below:

```ruby
# ...

def response
  div attributes: { style: "background-image: url(#{ActionController::Base.helpers.asset_path('image.png')});" } do
    # ...
    end
end

# ...
```
