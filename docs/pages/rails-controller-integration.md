# Rails Controller Integration

Pages are used as Rails view substitutes and therefore called in a Rails controller action:

{% code title="app/controllers/some_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::SomePage
  end

end
```
{% endcode %}

{% hint style="info" %}
A Matestack page will in this case be yielded into the Rails layout, unless the Rails layout is disabled in the controller via:`layout false`
{% endhint %}

## Passing data to pages

Sometimes you want to pass in data from the calling controller action into the page. This works the same way as seen at components:

```ruby
class SomeController < ActionController::Base

  include Matestack::Ui::Core::Helper

  def some_page
    render SomePage, foo: 'bar', bar: 'baz'
  end

end
```

```ruby
class SomePage < Matestack::Ui::Page

  required :foo
  optional :bar

  def response
    div id: "my-page" do
      plain context.foo # "bar"
      plain context.bar # "baz"
    end
  end

end
```
