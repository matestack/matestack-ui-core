# Page Concept

Show [specs](/spec/usage/base/page_spec.rb)

## A Page orchestrates components

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        plain "Hello World from Example Page!"
      end
    }
  end

end
```

## A Page can be used as a controller action response

`app/controllers/my_controller.rb`

```ruby
class MyController < ApplicationController

  # if not already included
  include Matestack::Ui::Core::ApplicationHelper

  def my_action
    responder_for(Pages::ExamplePage)
  end

end
```

## A Page can access request informations

`visit "/my_action_path/?foo=bar"`

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        plain context[:params][:foo] #--> bar
      end
    }
  end

end
```

## A Page can access controller instance variables

`app/controllers/my_controller.rb`

```ruby
class MyController < ApplicationController

  # if not already included
  include Matestack::Ui::Core::ApplicationHelper

  def my_action
    @foo = "bar"
    responder_for(Pages::ExamplePage)
  end

end
```

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        plain @foo #--> "bar"
      end
    }
  end

end
```

## A Page can resolve data in a prepare method, which runs before rendering

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @some_data = "data!"
  end

  def response
    components {
      div do
        plain @some_data #--> "data!"
      end
    }
  end

end
```
## A Page can use classic ruby within component orchestration

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @some_data = [1,2,3,4,5]
  end

  def response
    components {
      div do
        unless @some_data.empty?
          @some_data.each do |data|
            plain data
          end
        else
          plain "no data given"
        end
      end
    }
  end

end
```

## A Page can use page methods within component orchestration

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @some_data = [1,2,3,4,5]
  end

  def response
    components {
      div do
        unless @some_data.empty?
          @some_data.each do |data|
            plain calculated_value(data)
          end
        else
          plain "no data given"
        end
      end
    }
  end

  def calculated_value data
    return data*2
  end

end
```

## A Page can structure the response using local partials

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div do
        partial :my_simple_partial
        br
        partial :my_partial_with_param, "foo"
        br
        partial :my_partial_with_partial
      end
    }
  end

  def my_simple_partial
    partial {
      span id: "my_simple_partial" do
        plain "some content"
      end
    }
  end

  def my_partial_with_param some_param
    partial {
      span id: "my_partial_with_param" do
        plain "content with param: #{some_param}"
      end
    }
  end

  def my_partial_with_partial
    partial {
      span id: "my_partial_with_partial" do
        partial :my_simple_partial
      end
    }
  end

end
```

renders to:

```HTML
<div>

  <span id="my_simple_partial">
    some content
  </span>

  <br/>

  <span id="my_partial_with_param">
    content with param: foo
  </span>

  <br/>

  <span id="my_partial_with_partial">

    <span id="my_simple_partial">
      some content
    </span>

  </span>

</div>
```
## A Page can structure the response using partials from included modules

`app/matestack/pages/my_shared_partials.rb`

```ruby
module Pages::MySharedPartials

  def my_partial_with_param some_param
    partial {
      span id: "my_partial_with_param" do
        plain "content with param: #{some_param}"
      end
    }
  end

end
```

`app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  include Pages::MySharedPartials

  def response
    components {
      div do
        partial :my_simple_partial
        br
        partial :my_partial_with_param, "foo"
        br
        partial :my_partial_with_partial
      end
    }
  end

  def my_simple_partial
    partial {
      span id: "my_simple_partial" do
        plain "some content"
      end
    }
  end

  def my_partial_with_partial
    partial {
      span id: "my_partial_with_partial" do
        partial :my_simple_partial
      end
    }
  end

end
```

renders to:

```HTML
<div>

  <span id="my_simple_partial">
    some content
  </span>

  <br/>

  <span id="my_partial_with_param">
    content with param: foo
  </span>

  <br/>

  <span id="my_partial_with_partial">

    <span id="my_simple_partial">
      some content
    </span>

  </span>

</div>
```
