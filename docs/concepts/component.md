# Component Concept

Show [specs](../../spec/usage/base/component_spec.rb)

A component allows you to define reusable UI elements.

## Static components

In the beginning, we will ony use static components. Later, we introduce dynamic components that integrate Vue.js!

### A simple static component

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

### Multiple components may live in one namespace

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

### Camelcased module or class names

Those are referenced with their downcased counterpart! As an example, we define the camelcased component in `my_component/cell/my_component.rb`

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

### Custom components in your own Matestack project

To create a custom component, simply create it in your `app/matestack/components` folder like so: `my_component/cell/my_component.rb`.

```ruby
class Components::MyComponent::Cell::MyComponent < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

We will also create another custom component in the same namespace: `app/matestack/components/my_component/cell/my_second_component.rb`

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

Now, we add both to our example page using a *prefixed 'custom_'* to reference them!

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

Notice how, if namespace and component name are the same, can skip adding the component name for the first custom component! The output looks like this:

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

## Dynamic components

So far, we have only used static components. All components that inherit from 'Component::Cell::Static'" get rendered without any javascript involved.


### Async wrappers to add basic dynamic behavior

We create a custom *static* component in `app/matestack/components/static/cell/component.rb`

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

and add it to our example page, wrapping it into an *async event* to make it *dynamic*!

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

### Dynamic content with integrated Vue.js

We create a custom dynamic component in `app/matestack/components/dynamic/cell/component.rb`. Notice that we inherit from *a different class* than before: 'Component::Cell::Dynamic'

```ruby
class Dynamic::Cell::Component < Component::Cell::Dynamic

  def response
    components {
      div id: "my-component" do
        plain "I'm a fancy dynamic component!"
        plain "{{dynamic_value}}"
      end
    }
  end

end
```

The JavaScript part is defined in `app/matestack/components/dynamic/js/component.js`

```javascript
MatestackUiCore.Vue.component('dynamic-component-cell', {
  mixins: [MatestackUiCore.componentMixin],
  data: function data() {
    return {
      dynamic_value: "foo"
    };
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "bar"
    }, 300);
  }
});
```

We add the dynamic component to our example page as usual:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        dynamic_component
      end
    }
  end

end
```

On initial pageload, this is the HTML we're receiving:

```html
<div id="div-on-page">
  <div id="my-component">
    I'm a fancy dynamic component!
    foo
  </div>
</div>
```

And after 300ms, *foo* changes into *bar* dynamically - magic!

## Component configuration

Below, we give an overview of the various possibilities Matestack gives you with your components!

### Passing options to components

By passing options to your component, they get even more useful and flexible!

#### Passing options as a hash

As before, we create our component in it's respective file:

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
      end
    }
  end

end
```

On our example page, we directly pass the options to our static component as shown below:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @hello = "hello!"
  end

  def response
    components {
      div id: "div-on-page" do
        static_component some_option: @hello, some_other: { option: "world!" }
      end
    }
  end

end
```

The outcome is quite as expected:

```html
<div id="div-on-page">
  <div id="my-component">
    I'm a static component and got some option: hello! and some other option: world!
  </div>
</div>
```

#### Introducing required options

This feature is pretty straightforward - just declare your options as required key in the component config!

```ruby
class Static::Cell::SpecialComponent < Component::Cell::Static

  REQUIRED_KEYS = [:some_option]

  def response
    components {
      div id: "my-component" do
        plain "I'm a static component and got some option: #{@options[:some_option]} and some other option: #{@options[:some_other][:option]}"
      end
    }
  end

end
```

Notice that we *do not* pass the required option to our component on the example page:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_specialComponent some_other: { option: "world!" }
      end
    }
  end

end
```

Which leads to an error message:

```html
"div > static_specialComponent > required key 'some_option' is missing"
```

#### Options validation

Coming soon, stay tuned!

### Create even more flexible components using slots

Similar to named slots in Vue.js, slots in Matestack allow you to create useful placeholders.

#### Slots on the page instance scope

We define our slots within the component file as shown below:

```ruby
class Static::Cell::Component < Component::Cell::Static

  def prepare
    @foo = "foo from component"
  end

  def response
    components {
      div id: "my-component" do
        slot @options[:my_first_slot]
        br
        slot @options[:my_second_slot]
      end
    }
  end

end
```

Then, we can pass arguments for those slots on the example page. This is similar to how options work.

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div do
        static_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
      end
    }
  end

  def my_simple_slot
    slot {
      span id: "my_simple_slot" do
        plain "some content"
      end
    }
  end

  def my_second_simple_slot
    slot {
      span id: "my_simple_slot" do
        plain @foo
      end
    }
  end

end
```

This gets rendered into HTML as shown below. Notice that the `@foo` from the component configuration got overwritten by the page's local `@foo`!

```html
<div>
  <div id="my-component">
    <span id="my_simple_slot">
      some content
    </span>
    <br/>
    <span id="my_simple_slot">
      foo from page
    </span>
  </div>
</div>
```

#### Using slots of components within components

To use `component instance scope slots`, first we define slots within a static component:

```ruby
class Static::Cell::Component < Component::Cell::Static

  def prepare
    @foo = "foo from component"
  end

  def response
    components {
      div id: "my-component" do
        static_otherComponent slots: {
          my_slot_from_component: my_slot_from_component,
          my_slot_from_page: @options[:my_slot_from_page]
        }
      end
    }
  end

  def my_slot_from_component
    slot {
      span id: "my-slot-from-component" do
        plain @foo
      end
    }
  end

end
```

And another component:

```ruby
class Static::Cell::OtherComponent < Component::Cell::Static

  def prepare
    @foo = "foo from other component"
  end

  def response
    components {
      div id: "my-other-component" do
        slot @options[:slots][:my_slot_from_component]
        br
        slot @options[:slots][:my_slot_from_page]
        br
        plain @foo
      end
    }
  end

end
```

Then, we put both components to use on our example page:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "page-div" do
        static_component my_slot_from_page: my_slot_from_page
      end
    }
  end

  def my_slot_from_page
    slot {
      span id: "my-slot-from-page" do
        plain @foo
      end
    }
  end

end
```

This gets rendered into the HTML below:

```html
<div id="page-div">
  <div id="my-component">
    <div id="my-other-component">
      <span id="my-slot-from-component">
        foo from component
      </span>
      <br/>
      <span id="my-slot-from-page">
        foo from page
      </span>
      <br/>
      foo from other component
    </div>
  </div>
</div>
```

This may seem complicated at first, but it can provide valuable freedom of configuration and great fallbacks in more complex scenarios!

### Yielding inside components

Components can yield a block with access to scope, where a block is defined. This works like *yield* usually works in Ruby. But make sure to explicitly call *'yield_components'* within your component configuration!

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        yield_components
      end
    }
  end

end
```

Pass a block to your component on the page as shown below:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "div-on-page" do
        static_component do
          plain @foo
        end
      end
    }
  end

end
```

Not too fancy of an example, but this is the result:

```html
<div id="div-on-page">
  <div id="my-component">
    foo from page
  </div>  
</div>
```

### Partials

Use partials to keep your code dry and indentation layers manageable!

#### Local partials on component level

Define your component. This time, we will also define a partial in addition to the response.

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        partial :my_partial, "foo from component"
      end
    }
  end

  def my_partial text
    partial {
      plain text
    }
  end

end
```

As everything we need is already defined in the component, we can simply use it on our example page:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_component
      end
    }
  end

end
```

The outcome is our usual, boring HTML response. Continue below the HTML snippet for more exciting example of partial usage!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from component
  </div>
</div>
```

#### Modules: Partials on steriods!

Extract code snippets to modules for an even better project structure. Fist, create a module:

```ruby
module MySharedPartials

  def my_partial text
    partial {
      plain text
    }
  end

end
```

Include the module in your component as shown below:

```ruby
class Static::Cell::Component < Component::Cell::Static

  include MySharedPartials

  def response
    components {
      div id: "my-component" do
        partial :my_partial, "foo from component"
      end
    }
  end

end
```

Use the component on the example page as we've done before:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_component
      end
    }
  end

end
```

We may have seen the output before, but have you noticed that the component configuration reads much nicer?!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from component
  </div>
</div>
```

Try combining partials with options and slots for maximum readability, dryness and fun!

### Arguments

If no hash was given, a component can also access/accept a simple argument!

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain @argument
      end
    }
  end

end
```

Just make sure to pass one on the example page:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_component "foo from page"
      end
    }
  end

end
```

No miracle to find here, just what we expected!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from page
  </div>
</div>
```

### Prepare

Use a prepare method to resolve data before rendering a component!

```ruby
  class Static::Cell::Component < Component::Cell::Static

    def prepare
      @some_data = "some data"
    end

    def response
      components {
        div id: "my-component" do
          plain @some_data
        end
      }
    end

  end
```

In this example, the `@some_data` overwrites the `"foo from page"`-string passed on the example page:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_component "foo from page"
      end
    }
  end

end
```

This is the HTMl we receive:

```html
<div id="div-on-page">
  <div id="my-component">
    some data
  </div>
</div>
```

The prepare method comes in handy if you want to read from the database or want to modify content before displaying it!

### Request Access

A component can also access request informations, e.g. by reading the `@url_params`. We do this in our component defined below:

```ruby
class Static::Cell::Component < Component::Cell::Static

  def response
    components {
      div id: "my-component" do
        plain @url_params[:foo]
      end
    }
  end

end
```

On our example page, we then use the component as usual.

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        static_component "foo from page"
      end
    }
  end

end
```

Now if we visit our component, e.g. via `/component_test?foo=bar`, the component reads the `[:foo]` from the params and displays it like so:

```html
<div id="div-on-page">
  <div id="my-component">
    bar
  </div>
</div>
```

## More coming soon!

Stay tuned for this documentation page has been recently updated and will receive updates in the close future.
