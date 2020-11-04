# Component API

See below for an overview of the various possibilities Matestack provides for
component implementation:

## Response

Use the `response` method to define the UI of the component by using other components.

```ruby
  class Some::Component < Matestack::Ui::Component

    def response
      div id: "my-component" do
        plain "hello world!"
      end
    end

  end
```

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      some_component
    end
  end

end
```

This is the HTML which gets created:

```html
<div id="div-on-page">
  <div id="my-component">
    hello world!
  </div>
</div>
```

If no `response` method is defined, matestack will look for a corresponding `HAML`
template file lying next to Ruby component file.

## Prepare

Use a prepare method to resolve data before rendering a component!

```ruby
  class Some::Component < Matestack::Ui::Component

    def prepare
      @some_data = "some data"
    end

    def response
      div id: "my-component" do
        plain @some_data
      end
    end

  end
```

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      some_component
    end
  end

end
```

This is the HTML which gets created:

```html
<div id="div-on-page">
  <div id="my-component">
    some data
  </div>
</div>
```

The prepare method comes in handy to read from the database or to resolve content
before displaying it!

## Params access

A component can access request information, e.g. url query params, by calling
the `params` method:

```ruby
class Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      plain params[:foo]
    end
  end

end
```

On the example page, reference the component as usual.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      some_component
    end
  end

end
```

Now, visiting the respective route to the page, e.g. via `/xyz?foo=bar`, the component
reads the `[:foo]` from the params and displays it like so:

```html
<div id="div-on-page">
  <div id="my-component">
    bar
  </div>
</div>
```

## Passing options to components

### Define optional and required properties

Matestack components give you the option to define required and optional
properties for a component. It creates helpers for these properties automatically.

#### Requires

Required properties are required for your component to work, like the name suggests.
If at least one required property is missing a `Matestack::Ui::Core::Properties::PropertyMissingException`
is raised.

Declare your required properties by calling `requires` as follows:

```ruby
class SomeComponent < Matestack::Ui::Component

  requires :some_property, :some_other

end
```

You then can use these properties simply by calling the provided helper method,
which is generated for you. The helper method name corresponds to the passed
property name.

```ruby
class SomeComponent < Matestack::Ui::Component

  requires :some_property, :some_other

  def response
     display some_property plain inside a div and some_other property inside a paragraph beneath it
    div do
      plain some_property
    end
    paragraph text: some_other
  end

end
```

#### Optional

To define optional attributes you can use the same syntax as `requires`.
Just use `optional` instead of `requires`. Optional attributes are optional
and not validated for presence like required attributes.

```ruby
class SomeComponent < Matestack::Ui::Component

  optional :optional_property, :other_optional_property  optional properties could be empty

  def response
     display optional_property plain inside a div and other_optional_property property inside a paragraph beneath it
    div do
      plain optional_property
    end
    paragraph text: other_optional_property
  end

end
```

#### Passing properties to components

Pass the properties as a hash directly to the component when calling it.
You can pass any object you like and use it in the component with the helper.

```ruby
class SomeComponent < Matestack::Ui::Component

  requires :some_option,
  optional :some_other  optional properties could be empty

  def response
    div do
      plain some_option
    end
    if some_other.present?
      paragraph text: some_other[:option]
    end
  end

end
```

Use it in the example page and pass in the properties as a hash
```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @hello = "hello!"
  end

  def response
    div id: "div-on-page" do
      some_component some_option: @hello, some_other: { option: "world!" }
    end
  end

end
```

The outcome is quite as expected:

```html
<div id="div-on-page">
  <div>
    hello!
  </div>
  <p>world!</p>
</div>
```

#### Alias properties

Matestack tries to prevent overriding existing methods while creating helpers.
If you pass a property with a name that matches any instance method of your
component matestack will raise a `Matestack::Ui::Core::Properties::PropertyOverwritingExistingMethodException`.
To use property names that would raise this exception, simply provide an alias
name with the `as:` option. You can then use the alias accordingly.

```ruby
class SomeComponent < Matestack::Ui::Component
  requires :foo, :bar, method: { as: :my_method }
  optional response: { as: :my_response }

  def response
    div do
      plain "#{foo} - #{bar} - #{my_method}"  string concatenation of properties foo, bar, and method aliased as my_method
    end
    paragraph my_response if my_response.present?  response property aliased as my_response inside a paragraph if it is present
  end
end
```

Some common names that could not be used as properties:
```ruby
:method,
:params
```

## Arguments

If no hash was given, a component can also access/accept a simple argument!

```ruby
class Components::Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      plain @argument
    end
  end

end
```

Just make sure to pass an argument on the example page:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
       simply pass a string here
      some_component "foo from page"
    end
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

## Yielding inside components

Components can yield a block with access to scope, where a block is defined.
This works the way *yield* usually works in Ruby.
But make sure to explicitly call *'yield_components'* within the component response!

```ruby
class Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      yield_components
    end
  end

end
```

Pass a block to a component on the page as shown below:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    div id: "div-on-page" do
      some_component do
        plain @foo
      end
    end
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

## Partials

Use partials to keep the code dry and indentation layers manageable!

### Local partials on component level

In the component definition, see how this time from inside the response, the
`my_partial` method below is called:

```ruby
class Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      my_partial "foo from component"
    end
  end

  def my_partial text
    plain text
  end

end
```

As everything is already defined in the component, calling the `some_component`
on the example page is all there is to do:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      custom_some_component
    end
  end

end
```

The outcome is the usual, boring HTML response. Below the HTML snippet,
a more exciting example of partial usage is waiting!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from component
  </div>
</div>
```

### Modules: Partials on steriods!

Extract code snippets to modules for an even better project structure. First,
create a module:

```ruby
module MySharedPartials

  def my_partial text
    plain text
  end

end
```

Include the module in the component:

```ruby
class Some::Component < Matestack::Ui::Component

  include MySharedPartials

  def response
    div id: "my-component" do
      my_partial "foo from component"
    end
  end

end
```

Then reference the component on the example page as before:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      some_component
    end
  end

end
```

The output is unspectacular in this example, but more complex codebases will
greatly benefit from this refactoring option!

```html
<div id="div-on-page">
  <div id="my-component">
    foo from component
  </div>
</div>
```

Try combining partials with options and slots (see below) for maximum readability,
dryness and fun!


## Slots

Similar to named slots in Vue.js, slots in Matestack allows us to inject whole
UI snippets into the component. It's a more specific yielding mechanism as you will yield
multiple "named" blocks into the component. Each of these blocks can be referenced
and positioned independently in the component,

### Slots on the page instance scope

Define the slots within the component file as shown below. Please make sure to inject
slots within a hash `slots: { ... }` into the component.

```ruby
class Some::Component < Matestack::Ui::Component

  requires :slots

  def prepare
    @foo = "foo from component"
  end

  def response
    div id: "my-component" do
      slot slots[:my_first_slot]
      br
      slot slots[:my_second_slot]
    end
  end

end
```

Slots have access to the scope of the class, where they are defined. In this case `@foo`

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    div do
      some_component slots: {
        my_first_slot: my_simple_slot,
        my_second_slot: my_second_simple_slot
      }
    end
  end

  def my_simple_slot
    slot do
      span id: "my_simple_slot" do
        plain "some content"
      end
    end
  end

  def my_second_simple_slot
    slot do
      span id: "my_simple_slot" do
        plain @foo
      end
    end
  end

end
```

This gets rendered into HTML as shown below. Notice that the `@foo` from the component
configuration got overwritten by the page's local `@foo`!

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

### Using slots of components within components

To use *component instance scope slots*, first define slots within a static component:

```ruby
class Other::Component < Matestack::Ui::Component

  requires :slots

  def prepare
    @foo = "foo from other component"
  end

  def response
    div id: "my-other-component" do
      slot slots[:my_slot_from_component]
      br
      slot slots[:my_slot_from_page]
      br
      plain @foo
    end
  end

end
```

and also in some component:

```ruby
class Some::Component < Matestack::Ui::Component

  requires :slots

  def prepare
    @foo = "foo from component"
  end

  def response
    div id: "my-component" do
      other_component slots: {
        my_slot_from_component: my_slot_from_component,
        my_slot_from_page: slots[:my_slot_from_page]
      }
    end
  end

  def my_slot_from_component
    slot do
      span id: "my-slot-from-component" do
        plain @foo
      end
    end
  end

end
```

Then, put both components (note that some component uses other component so
that's how they're both in here) to use on the example page:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    div id: "page-div" do
      some_component slots: { my_slot_from_page: my_slot_from_page }
    end
  end

  def my_slot_from_page
    slot do
      span id: "my-slot-from-page" do
        plain @foo
      end
    end
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

This may seem complicated at first, but it can provide valuable freedom of
configuration and great fallbacks in more complex scenarios!
