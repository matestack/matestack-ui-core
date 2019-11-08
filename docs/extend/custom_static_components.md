# Custom static components

All `static components` inherit from the `Matestack::Ui::StaticComponent` class.

## A simple static component

Define the component in `app/matestack/components/component1.rb` like so

```ruby
class Components::Component1 < Matestack::Ui::StaticComponent

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and add it to the response part of an Example Page that lives somewhere in `app/matestack/pages/example_app/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        # below is the reference to the custom component
        custom_component1
      end
    }
  end

end
```

This will get rendered into

```html
<div id="div-on-page">
  <div id="my-component">
    I'm a static component!
  </div>
</div>
```

## Multiple components may live in one namespace

Define the first component in `app/matestack/components/namespace1/component1.rb`

```ruby
class Components::Namespace1::Component1 < Matestack::Ui::StaticComponent

  def response
    components {
      div class: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and define a second component in the same namespace: `app/matestack/components/namespace1/component2.rb`

```ruby
class Components::Namespace1::Component2 < Matestack::Ui::StaticComponent

  def response
    components {
      div class: "my-component-2" do
        plain "I'm a second custom static component!"
      end
    }
  end

end
```

then add both components to the response part of the Example Page in `app/matestack/pages/example_page.rb`

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

   def response
     components {
       div id: "div-on-page" do
         custom_namespace1_component1
         custom_namespace1_component2
       end
     }
   end

end
```  

The output looks like this:

```html
<div id="div-on-page">
  <div class="my-component-1">
    I'm a static component!
  </div>
  <div class="my-component-2">
    I'm a second custom static component!
  </div>
</div>
```

## Camelcased module or class names

Components named in camelcase  are referenced with their downcased counterpart!
As an example, define the camelcased component in `app/matestack/components/my_component.rb`

```ruby
class Components::MyComponent < Matestack::Ui::StaticComponent

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and add it to the response part of the Example Page (`app/matestack/pages/example_page.rb`, remember?) via *downcased reference*

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        # if we would try to use custom_my_component was called, this would refer to Components::My::Component
        # and woulnd't deliver the desired outcome (and therefore throw an error)
        custom_myComponent
      end
    }
  end

end
```

As expected, it will get rendered into

```html
<div id="div-on-page">
  <div id="my-component-1">
    I'm a static component!
  </div>
</div>
```
