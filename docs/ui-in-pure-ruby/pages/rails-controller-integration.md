# Rails Controller Integration

Pages are used as Rails view substitutes and therefore called in a Rails controller action:

{% code title="app/controllers/some\_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::SomePage
  end

end
```
{% endcode %}

