# App API

An app defines a layout within its `response` method and yields the content of a page in its layout.

## Response

Use the `response` method to define the UI of the app by using Matestack's HTML rendering and optionally calling components.

```ruby
class SomeApp < Matestack::Ui::App

  def response
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      yield
    end
    footer do
      div id: "div-on-app" do
        SomeComponent.()
      end
    end
  end

end
```

## Partials and helper methods

Use partials to keep the code dry and indentation layers manageable!

### Local partials on page level

In the page definition, see how this time from inside the response, the `my_partial` method below is called:

```ruby
class SomeApp < Matestack::Ui::App

  def response
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      yield
    end
    footer do
      div id: "div-on-app" do
        SomeComponent.()
      end
      my_partial "foo from app"
    end
  end
  
  private # optionally mark your partials as private

  def my_partial text
    div class: "nested" do
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
    div class: "nested" do
      plain text
    end
  end

end
```

Include the module in the page:

```ruby
class SomeApp < Matestack::Ui::App

  include MySharedPartials

  def response
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      yield
    end
    footer do
      div id: "div-on-app" do
        SomeComponent.()
      end
      my_partial "foo from app"
    end
  end

end
```

### Helper methods

Not only can instance methods be used as "partials" but as general helpers performing any kind of logic or data resolving:

```ruby
class SomeApp < Matestack::Ui::App

  def response
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      if is_admin?
        yield
      else
        plain "not authorized"
      end 
    end
  end

  private # optionally mark your helper methods as private

  def is_admin?
    true # some crazy Ruby logic!
  end
  
end
```

## Prepare

Use a prepare method to resolve instance variables before rendering a page if required.

```ruby
class SomeApp < Matestack::Ui::App

  def prepare
    @heading = "Foo"
  end

  def response
    h1 @heading
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      yield
    end
  end
  
end

```

## Params access

An app can access request information, e.g. url query params, by calling the `params` method:

```ruby
class SomeApp < Matestack::Ui::App

  def response
    nav do 
      a path: some_rails_path, text: "Navigate!"
    end
    main do
      plain params[:foo] # "bar" 
      yield
    end
  end
  
end
```

Now, visiting the respective route to the page, e.g. via `/xyz?foo=bar`, the page reads the `[:foo]` from the params and displays it.

