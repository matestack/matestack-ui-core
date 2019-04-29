# Component Concept

Show [specs](../../spec/usage/base/component_spec.rb)

A component allows you to define reusable UI elements.

## A simple static component

Define the component in `component1/cell/component1.rb`

```ruby
class Component1::Cell::Component1 < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and add it to the response part of our Example Page

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        # below is our component
        component1
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

Define the first component in `namespace1/cell/component1.rb`

```ruby
class Namespace1::Cell::Component1 < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

Define the second component in `namespace1/cell/component2.rb`

```ruby
class Namespace1::Cell::Component2 < Component::Cell::Static

  def response
    components {
      div id: "my-component-2" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and add both components to the response part of our Example Page

```ruby
class ExamplePage < Page::Cell::Page

   def response
     components {
       div id: "div-on-page" do
         namespace1_component1
         namespace1_component2
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
  <div id="my-component-2">
    I'm a static component!
  </div>
</div>
```

## Camelcased module or class names are referenced with their downcased counterpart

Define the camelcased component in `my_component/cell/my_component.rb`

```ruby
class MyComponent::Cell::MyComponent < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and add it to the response part of our Example Page via *downcased reference*

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        # notice we do not reference our component as my_component
        # as this would refer to My::Cell::Component
        myComponent
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

## Create custom components in your own Matestack projects

To create a custom component, simply define it in e.g. `app/matestack/components/my_component/cell/my_component.rb`

```ruby
class MyComponent::Cell::MyComponent < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

We will also create another custom component in `app/matestack/components/my_component/cell/my_second_component.rb`

```ruby
class Components::MyComponent::Cell::MySecondComponent < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a second custom static component!"
      end
    }
  end

end
```

and add both to our example page using a *prefixed 'custom_'* to reference them!

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_myComponent
        custom_myComponent_mySecondComponent
      end
    }
  end

end
```

to achieve the desired output of


```html
<div id="div-on-page">
  <div id="my-component-1">
    I'm a static component!
  </div>
  <div id="my-component-2">
    I'm a second custom static component!
  </div>
</div>
```

## Static components

So far, we have only used static components. All components that inherit from 'Component::Cell::Static'" get rendered without any javascript involved.


## To add basic dynamic behaviour, pages can use an async component to wrap static components

We create a custom static component in `app/matestack/components/static/cell/component.rb`

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
        plain DateTime.now.strftime('%Q')
      end
    }
  end

end
```

and add it to our example page, wrapping it into an *async event!*

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        async rerender_on: "my_event" do
          static_component
        end
      end
    }
  end

end
```

Now, the page will respond with the basic static content, but the custom component (visible by looking at the timestamp) will get rerendered on every instance of *"my_event"*. Awesome!
