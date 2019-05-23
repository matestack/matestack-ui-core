# Component Concept

Show [specs](../../spec/usage/base/component_spec.rb)

A component is used to define reusable UI elements. This documentation enables anyone to write custom components that live within a Rails application. All custom components need a *prefixed 'custom_'* to be referenced within the `app/matestack/` folder in a Rails application.

To extend the available core components, feel free to fork this repo and create them within the `app/concepts` folder, analogous to the existing core components.

In the beginning, static components are introduced. Later, dynamic components follow by integrating Vue.js. After that, all the configuration options for Matestack components get explained!  

## Static components

All static components inherit from the `Component::Cell::Static` class and get rendered without any javascript involved.

### A simple static component

Define the component in `app/matestack/components/component1/cell/component1.rb` like so

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

and add it to the response part of an Example Page that lives somewhere in `app/matestack/pages/example_app/example_page.rb`

```ruby
class ExamplePage < Page::Cell::Page

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

### Multiple components may live in one namespace

Define the first component in `app/matestack/components/namespace1/cell/component1.rb`

```ruby
class Namespace1::Cell::Component1 < Component::Cell::Static

  def response
    components {
      div class: "my-component" do
        plain "I'm a static component!"
      end
    }
  end

end
```

and define a second component in the same namespace: `app/matestack/components/namespace1/cell/component2.rb`

```ruby
class Namespace1::Cell::Component2 < Component::Cell::Static

  def response
    components {
      div class: "my-component-2" do
        plain "I'm a second custom static component!"
      end
    }
  end

end
```

then add both components to the response part of the Example Page in `app/matestack/pages/example_app/example_page.rb`

```ruby
class ExamplePage < Page::Cell::Page

   def response
     components {
       div id: "div-on-page" do
         custom_namespace1
         custom_namespace1_component1
         custom_namespace1_component2
       end
     }
   end

end
```  

Noticed that `Namespace1::Cell::Component1` gets referenced twice?
As namespace and component name are the same, the component name may be skipped!
The output looks like this:

```html
<div id="div-on-page">
  <div class="my-component-1">
    I'm a static component!
  </div>
  <div class="my-component-1">
    I'm a static component!
  </div>
  <div class="my-component-2">
    I'm a second custom static component!
  </div>
</div>
```

### Camelcased module or class names

Components named in camelcase  are referenced to with their downcased counterpart!
As an example, define the camelcased component in `app/matestack/components/my_component/cell/my_component.rb`

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

and add it to the response part of the Example Page (`app/matestack/pages/example_app/example_page.rb`, remember?) via *downcased reference*

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        # if my_component was called, this would refer to My::Cell::Component
        # and woulnd't deliver the desired outcome
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

## Dynamic components

So far, all custom components were static ones. Reminder: All components that inherit from `Component::Cell::Static` get rendered without any javascript involved. But static components can also be wrapped inside dynamic components to create, well, dynamic behavior!

### Async wrapper to add basic dynamic behavior

Create a custom *static* component in `app/matestack/components/static/cell/component.rb`

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

and add it to the Example Page, wrapping it into an *async component* to make it *dynamic*! The *async component* is a core component and therefore does not need a *custom_* prefix.

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        async rerender_on: "my_event" do
          custom_static_component
        end
      end
    }
  end

end
```

Now, the page will respond with static content, but gets rerendered (visible by looking at the timestamp) whenever *"my_event"* happens. Awesome!

### Dynamic content with integrated Vue.js

To create a custom dynamic component, create an associated file such as `app/matestack/components/dynamic/cell/component.rb`.


In contrast to static components that inherit from `Component::Cell::Static`, a custom dynamic component inherits from *a different class*, `Component::Cell::Dynamic`:

```ruby
class Dynamic::Cell::Component < Component::Cell::Dynamic

  def response
    components {
      div id: "my-component" do
        plain "I'm a fancy dynamic component! Call me {{dynamic_value}}!"
      end
    }
  end

end
```

The JavaScript part is defined in `app/matestack/components/dynamic/js/component.js` as a Vue.js component:

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

Add the dynamic component to an example page the same way it is done with static components:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_dynamic_component
      end
    }
  end

end
```

On initial pageload, this is the HTML received:

```html
<div id="div-on-page">
  <div id="my-component">
    I'm a fancy dynamic component! Call me foo!
  </div>
</div>
```

And after 300ms, *foo* changes into *bar* dynamically - magic!

## Component configuration

See below for an overview of the various possibilities Matestack provides for component configuration, both for custom and core components!

### Passing options to components

By passing options to a component, they get very flexible and can take various input, e.g. *i18n* strings or *instance variables*!

#### Passing options as a hash

As before, create a component in it's respective file, in this case `app/matestack/components/static/cell/component.rb`:

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

On the example page, directly pass the options to the static component as shown below:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @hello = "hello!"
  end

  def response
    components {
      div id: "div-on-page" do
        custom_static_component some_option: @hello, some_other: { option: "world!" }
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

This feature is pretty straightforward - just declare the options as a required key in the component config!

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

Notice that this example *does not* pass the required option to the component on the example page, provoking an error message:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_static_specialComponent some_other: { option: "world!" }
      end
    }
  end

end
```

The error message looks like this:

```html
"div > custom_static_specialComponent > required key 'some_option' is missing"
```

#### Options validation

Coming soon, stay tuned!

### Create even more flexible components using slots

Similar to named slots in Vue.js, slots in Matestack allow for useful placeholders.

#### Slots on the page instance scope

Define the slots within the component file as shown below:

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

Passing arguments for those slots on the example page works very similar to the options introduced above:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div do
        custom_static_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
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

To use *component instance scope slots*, first define slots within a static component:

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

Then, put both components to use on the example page:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "page-div" do
        custom_static_component my_slot_from_page: my_slot_from_page
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

Components can yield a block with access to scope, where a block is defined. This works the way *yield* usually works in Ruby. But make sure to explicitly call *'yield_components'* within the component configuration!

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

Pass a block to a component on the page as shown below:

```ruby
class ExamplePage < Page::Cell::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "div-on-page" do
        custom_static_component do
          plain @foo
        end
      end
    }
  end

end
```

Not a fancy example, but this is the result:

```html
<div id="div-on-page">
  <div id="my-component">
    foo from page
  </div>  
</div>
```

### Partials

Use partials to keep the code dry and indentation layers manageable!

#### Local partials on component level

In the component definition, see how this time from inside the response, the `my_partial` method below is called:

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

As everything is already defined in the component, calling the `custom_static_component` on the example page is all there is to do:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_static_component
      end
    }
  end

end
```

The outcome is the usual, boring HTML response. Below the HTML snippet, a more exciting example of partial usage is waiting!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from component
  </div>
</div>
```

#### Modules: Partials on steriods!

Extract code snippets to modules for an even better project structure. First, create a module:

```ruby
module MySharedPartials

  def my_partial text
    partial {
      plain text
    }
  end

end
```

Include the module in the component created in `app/matestack/components/component/cell/static.rb` as shown below:

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

Then reference the component on the example page as before:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_static_component
      end
    }
  end

end
```

The output is unspectacular in this example, but more complex codebases will greatly benefit from this configuration option!

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

Just make sure to pass an argument on the example page:

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        # simply pass a string here
        custom_static_component "foo from page"
      end
    }
  end

end
```

No miracle to find here, just what was expected!

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

This is the HTMl which gets created:

```html
<div id="div-on-page">
  <div id="my-component">
    some data
  </div>
</div>
```

The prepare method comes in handy to read from the database or to modify content before displaying it!

### Request Access

A component can also access request information, e.g. by reading the `@url_params`. Do this in the component defined below:

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

On the example page, reference the component as usual.

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      div id: "div-on-page" do
        custom_static_component "foo from page"
      end
    }
  end

end
```

Now, visiting the respective route to the page, e.g. via `/component_test?foo=bar`, the component reads the `[:foo]` from the params and displays it like so:

```html
<div id="div-on-page">
  <div id="my-component">
    bar
  </div>
</div>
```

## More coming soon!

Stay tuned for this documentation page has been recently updated and will receive updates in the close future.
