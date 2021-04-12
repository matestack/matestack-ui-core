# Page API

## Response

Use the `response` method to define the UI of the page by using Matestack's HTML rendering or calling components.

```ruby
class SomePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      SomeComponent.()
    end
  end

end
```

```ruby
  class SomeComponent < Matestack::Ui::Component

    def response
      div id: "my-component" do
        plain "hello world!"
      end
    end

  end
```

## Partials and helper methods

Use partials to keep the code dry and indentation layers manageable!

### Local partials on page level

In the page definition, see how this time from inside the response, the `my_partial` method below is called:

```ruby
class SomePage < Matestack::Ui::Page

  def response
    div id: "my-page" do
      my_partial "foo from page"
    end
  end

  private # optionally mark your partials as private

  def my_partial text
    div class: "nested"
      plain text
    end
  end

end
```

### Partials defined in modules

Extract code snippets to modules for an even better project structure. First, create a module:

```ruby
module MySharedPartials

  def my_partial text
    div class: "nested"
      plain text
    end
  end

end
```

Include the module in the page:

```ruby
class SomePage < Matestack::Ui::Page

  include MySharedPartials

  def response
    div id: "my-page" do
      my_partial "foo from component"
    end
  end

end
```

### Helper methods

Not only can instance methods be used as "partials" but as general helpers performing any kind of logic or data resolving:

```ruby
class SomePage < Matestack::Ui::Page

  def response
    div id: "my-page" do
      if is_admin?
        latest_users.each do |user|
          div do
            plain user.name # ...
          end
        end
      else
        plain "not authorized"
      end 
    end
  end

  private # optionally mark your helper methods as private

  def is_admin?
    true # some crazy Ruby logic!
  end

  def latest_users
    User.last(10) # calling ActiveRecord models for example
  end

end
```

## Prepare

Use a prepare method to resolve instance variables before rendering a page if required.

```ruby
class SomePage < Matestack::Ui::Page

  def prepare
    @some_data = "some data"
  end

  def response
    div id: "my-page" do
      plain @some_data
    end
  end

end
```

## Params access

A page can access request information, e.g. url query params, by calling the `params` method:

```ruby
class SomePage < Matestack::Ui::Page

  def response
    div id: "my-page" do
      plain params[:foo]
    end
  end

end
```

Now, visiting the respective route to the page, e.g. via `/xyz?foo=bar`, the page reads the `[:foo]` from the params and displays it.

## Passing data to pages

Sometimes you want to pass in data from the calling controller action into the page. This works the same way as seen at components:

```ruby
class SoomeController < ActionController::Base

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

