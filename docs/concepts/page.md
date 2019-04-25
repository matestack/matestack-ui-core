# Page Concept

Show [specs](../../spec/usage/base/app_spec.rb)

## A Page orchestrates components and can be used as a controller action response

`app/basemate/pages/example_page.rb`

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div do
        plain "Hello World from Example Page!"
      end
    }
  end

end
```

`app/controllers/my_controller.rb`

```ruby
class MyController < ApplicationController

  # if not already included
  include Basemate::Ui::Core::ApplicationHelper

  def my_action
    responder_for(ExamplePage)
  end

end
```

## A Page can access controller instance variables

`app/controllers/my_controller.rb`

```ruby
class MyController < ApplicationController

  # if not already included
  include Basemate::Ui::Core::ApplicationHelper

  def my_action
    @foo = "bar"
    responder_for(ExamplePage)
  end

end
```

`app/basemate/pages/example_page.rb`

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div do
        plain @foo #--> "bar"
      end
    }
  end

end
```
