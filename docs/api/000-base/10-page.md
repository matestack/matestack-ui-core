# Page

A page orchestrates components within its response method. A Rails controller
action references a page (and its corresponding app) in its render call. Thus a
matestack page substitutes a typical Rails view.

A page is a special kind of `Matestack::Ui::VueJsComponent`. Matestack will
therefore wrap the UI defined in the `response` method with some markup enabling
dynamic UI behavior and CSS styling.

## A Page orchestrates components

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def response
    div do
      plain "Hello World from Example Page!"
    end
  end

end
```

## A Page can be used as a controller action response

`app/controllers/my_controller.rb`

```ruby
class MyController < ApplicationController

  # if not already included
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app ExampleApp

  def my_action
    render ExampleApp::Pages
  end

end
```

## A Page can access request params

`visit "/my_action_path/?foo=bar"`

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def response
    div do
      plain params[:foo] #--> bar
    end
  end

end
```

## A Page can resolve data in a prepare method, which runs before rendering

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def prepare
    @some_data = "data!"
  end

  def response
    div do
      plain @some_data #--> "data!"
    end
  end

end
```
## A Page can use classic ruby within component orchestration

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def prepare
    @some_data = [1,2,3,4,5]
  end

  def response
    div do
      unless @some_data.empty?
        @some_data.each do |data|
          plain data
        end
      else
        plain "no data given"
      end
    end
  end

end
```

## A Page can use page methods within component orchestration

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def prepare
    @some_data = [1,2,3,4,5]
  end

  def response
    div do
      unless @some_data.empty?
        @some_data.each do |data|
          plain calculated_value(data)
        end
      else
        plain "no data given"
      end
    end
  end

  def calculated_value data
    return data*2
  end

end
```

## A Page can structure the response using local partials

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  def response
    div do
      my_simple_partial
      br
      my_partial_with_param "foo"
      br
      my_partial_with_partial
    end
  end

  def my_simple_partial
    span id: "my_simple_partial" do
      plain "some content"
    end
  end

  def my_partial_with_param some_param
    span id: "my_partial_with_param" do
      plain "content with param: #{some_param}"
    end
  end

  def my_partial_with_partial
    span id: "my_partial_with_partial" do
      my_simple_partial
    end
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
    span id: "my_partial_with_param" do
      plain "content with param: #{some_param}"
    end
  end

end
```

`app/matestack/example_app/pages/example_page.rb`

```ruby
class ExampleApp::Pages < Matestack::Ui::Page

  include Pages::MySharedPartials

  def response
    div do
      my_simple_partial
      br
      my_partial_with_param "foo"
      br
      my_partial_with_partial
    end
  end

  def my_simple_partial
    span id: "my_simple_partial" do
      plain "some content"
    end
  end

  def my_partial_with_partial
    span id: "my_partial_with_partial" do
      my_simple_partial
    end
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
