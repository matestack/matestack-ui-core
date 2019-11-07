# Component Concept

Show [specs](/spec/usage/base/component_spec.rb).

Components are used to define reusable UI elements. The `matestack-ui-core` contains a number of generic, so-called `core components`, but anyone can extend them and write `custom components` that live within a his or her application and cater a specific or unique need.

This document aims to give a brief introducing to the different kinds of components (with links to further sources) and serves as a manual on [how to configure your components](#component-configuration).

## Core Components

See [here](/docs/components/README.md) for a list of available `core components`. In general, they are separated into HTML-only **static** components and **dynamic** components that come with Javascript-powered, dynamic behaviour.

If you miss a component that you think we're missing in the `core components` right now, [create an issue](https://github.com/basemate/matestack-ui-core/issues/new) in our GitHub!

If you have created your own component and feel like it would be a great addition to the `core components`, please [create a pull request](https://github.com/basemate/matestack-ui-core/compare) including tests and documentation.

To extend the available core components, just fork [the repo](https://github.com/basemate/matestack-ui-core) and create them within the `app/concepts` folder, analogous to the existing core components - and you're always invited to reach out to [our community](https://gitter.im/basemate/community) if you face any problems!

## Custom Components

By definition, `custom components` only live within your application. In Rails applications, they are put into the `app/matestack/components/` directory. To use them on your `apps` and `pages`, you need to add a *prefixed 'custom_'*. This clearly differentiates them from the vanilla `core components`.

### Static Components

See [here](/docs/extend/custom_static_components.md) for an extensive guide on creating your own `custom static components`. Orchestrate existing `core components` to avoid repetition, or get creative and add your own `HAML` templates!

### Dynamic Components

See [here](/docs/extend/custom_dynamic_components.md) for an extensive guide on creating your own `custom dynamic components`. Those allow you to extend and create rich user exeriences by writing custom Vue.Js!

### Actionview Components

See [here](/docs/extend/custom_actionview_component.md) for a guide on creating custom `actionview components`, both `static` and `dynamic`. Those allow you to harness the power of various Rails `ActionView` helpers without including them in your `custom components`.

## Component configuration

See below for an overview of the various possibilities Matestack provides for component configuration, both for `custom components` and `core components`!

### Passing options to components

By passing options to a component, they get very flexible and can take various input, e.g. *i18n* strings or *instance variables*!

#### Passing options as a hash

As before, create a component in it's respective file, in this case `app/matestack/components/some/component.rb`:

```ruby
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @hello = "hello!"
  end

  def response
    components {
      div id: "div-on-page" do
        custom_some_component some_option: @hello, some_other: { option: "world!" }
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
class Components::SpecialComponent < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_specialComponent some_other: { option: "world!" }
      end
    }
  end

end
```

The error message looks like this:

```html
"div > custom_specialComponent > required key 'some_option' is missing"
```

#### Options validation

Coming soon, stay tuned!

### Create even more flexible components using slots

Similar to named slots in Vue.js, slots in Matestack allow for useful placeholders.

#### Slots on the page instance scope

Define the slots within the component file as shown below:

```ruby
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div do
        custom_some_component my_first_slot: my_simple_slot, my_second_slot: my_second_simple_slot
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
class Components::Some::Component < Matestack::Ui::StaticComponent

  def prepare
    @foo = "foo from component"
  end

  def response
    components {
      div id: "my-component" do
        custom_other_component slots: {
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
class Components::Other::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "page-div" do
        custom_some_component my_slot_from_page: my_slot_from_page
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
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    components {
      div id: "div-on-page" do
        custom_some_component do
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
class Components::Some::Component < Matestack::Ui::StaticComponent

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

As everything is already defined in the component, calling the `custom_some_component` on the example page is all there is to do:

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_some_component
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

Include the module in the component created in `app/matestack/components/some/component.rb` as shown below:

```ruby
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_some_component
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
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        # simply pass a string here
        custom_some_component "foo from page"
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
  class Components::Some::Component < Matestack::Ui::StaticComponent

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

```ruby
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_some_component
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
class Components::Some::Component < Matestack::Ui::StaticComponent

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
class Pages::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "div-on-page" do
        custom_some_component
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
