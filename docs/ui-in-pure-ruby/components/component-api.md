# Component API

See below for an overview of the various possibilities Matestack provides for component implementation:

## Response

Use the `response` method to define the UI of the component by using Matestack's HTML rendering or calling components.

```ruby
  class SomeComponent < Matestack::Ui::Component

    def response
      div id: "my-component" do
        plain "hello world!"
      end
      SomeOtherComponent.()
    end

  end
```

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      SomeComponent.()
    end
  end

end
```

## Partials and helper methods

Use partials to keep the code dry and indentation layers manageable!

### Local partials on component level

In the component definition, see how this time from inside the response, the `my_partial` method below is called:

```ruby
class SomeComponent < Matestack::Ui::Component

  def response
    div id: "my-component" do
      my_partial "foo from component"
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

Include the module in the component:

```ruby
class SomeComponent < Matestack::Ui::Component

  include MySharedPartials

  def response
    div id: "my-component" do
      my_partial "foo from component"
    end
  end

end
```

### Helper methods

Not only can instance methods be used as "partials" but as general helpers performing any kind of logic or data resolving:

```ruby
class SomeComponent < Matestack::Ui::Component

  def response
    div id: "my-component" do
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

Use a prepare method to resolve instance variables before rendering a component if required.

```ruby
  class SomeComponent < Matestack::Ui::Component

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
      SomeComponent.()
    end
  end

end
```

This is the HTML which gets created:

```markup
<div id="div-on-page">
  <div id="my-component">
    some data
  </div>
</div>
```

## Params access

A component can access request information, e.g. url query params, by calling the `params` method:

```ruby
class SomeComponent < Matestack::Ui::Component

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
     SomeComponent.()
    end
  end

end
```

Now, visiting the respective route to the page, e.g. via `/xyz?foo=bar`, the component reads the `[:foo]` from the params and displays it like so:

```markup
<div id="div-on-page">
  <div id="my-component">
    bar
  </div>
</div>
```

## Passing data to components

You often need to pass data into your component to make them reusable. You have multiple possibilities to do that:

### General options access

If you pass in a hash to a component...

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      SomeComponent.(foo: "bar")
    end
  end

end
```

...this hash is accessible via options in the component:

```ruby
class Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      plain options[:foo]
    end
  end

end
```

### Optional and required options

Matestack components give you the possibility to define an explicit API for your component describing required and optional options for a component. Using this approach, it's way easier to understand what data can be processed by your component.

{% hint style="info" %}
`required` and `optional` options will be deleted from the `options` hash and are only available via the `context` object.
{% endhint %}

#### Required options

Required options are required for your component to work, like the name suggests. If at least one required option is missing, an Exception is raised.

Declare your required options by calling `required` as follows:

```ruby
class SomeComponent < Matestack::Ui::Component

  required :some_property, :some_other

end
```

You then can use these options simply by calling the provided OpenStruct object `context`, which includes the injected options with their name:

```ruby
class SomeComponent < Matestack::Ui::Component

  required :some_property, :some_other

  def response
    # display some_property plain inside a div and some_other property inside a paragraph beneath it
    div do
      plain context.some_property
    end
    paragraph text: context.some_other
  end

end
```

#### Optional options

To define optional options you can use the same syntax as `required`. Just use `optional` instead of `required`. Optional options are optional and not validated for presence like required options.

```ruby
class SomeComponent < Matestack::Ui::Component

  optional :optional_property, :other_optional_property # optional properties could be empty

  def response
    div do
      plain context.optional_property
    end
    paragraph context.other_optional_property
  end

end
```

#### Passing more complex data structures to components

You can pass any object you like and use it in the component with the helper.

```ruby
class SomeComponent < Matestack::Ui::Component

  required :some_option,
  optional :some_other

  def response
    div do
      plain context.some_option
    end
    if context.some_other.present?
      paragraph context.some_other[:option]
    end
  end

end
```

Use it in the example page and pass in one option as a hash

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @hello = "hello!"
  end

  def response
    div id: "div-on-page" do
      SomeComponent.(some_option: @hello, some_other: { option: "world!" })
    end
  end

end
```

#### Alias properties

It's not possible to overwrite core methods of the OpenStruct object `context`

```markup
[:!, :!=, :!~, :<=>, :==, :===, :=~, :[], :[]=, :__id__, :__send__, :acts_like?, :as_json, :blank?, :byebug, :class, :class_eval, :clone, :dclone, :debugger, :deep_dup, :define_singleton_method, :delete_field, :dig, :display, :dup, :duplicable?, :each_pair, :enum_for, :eql?, :equal?, :extend, :freeze, :frozen?, :gem, :hash, :html_safe?, :in?, :inspect, :instance_eval, :instance_exec, :instance_of?, :instance_values, :instance_variable_defined?, :instance_variable_get, :instance_variable_names, :instance_variable_set, :instance_variables, :is_a?, :itself, :kind_of?, :load_dependency, :marshal_dump, :marshal_load, :method, :method_missing, :methods, :nil?, :object_id, :presence, :presence_in, :present?, :pretty_inspect, :pretty_print, :pretty_print_cycle, :pretty_print_inspect, :pretty_print_instance_variables, :private_methods, :protected_methods, :public_method, :public_methods, :public_send, :remote_byebug, :remove_instance_variable, :require_dependency, :require_or_load, :respond_to?, :send, :singleton_class, :singleton_method, :singleton_methods, :table, :table!, :taint, :tainted?, :tap, :then, :to_enum, :to_h, :to_json, :to_param, :to_query, :to_s, :to_yaml, :trust, :try, :try!, :unloadable, :untaint, :untrust, :untrusted?, :with_options, :yield_self]
```

If you somehow want to inject options with a key matching a core method of the OpenStruct object, simply provide an alias name with the `as:` option. You can then use the alias accordingly. A popular example would be the option called `class`

```ruby
class SomeComponent < Matestack::Ui::Component

  required :foo, :bar, class: { as: :my_class }

  def response
    div class: context.my_class do
      plain "#{context.foo} - #{context.bar}"
    end
  end

end
```

### Text argument

Sometimes you just want to pass in a simple \(text\) argument rather than a hash with multiple keys:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      # simply pass in a string here
      SomeComponent.("foo from page")
    end
  end

end
```

A component can access this text argument in various ways:

```ruby
class Some::Component < Matestack::Ui::Component

  def response
    div id: "my-component" do
      plain self.text # because such an argument is almost always a string
      # or
      plain context.text # for compatibility with older releases
    end
  end

end
```

This approach can be combined with injecting Hashes to components:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div id: "div-on-page" do
      # simply pass in a string here
      Some::Component.("foo from page", { foo: "bar" })
    end
  end

end
```

```ruby
class Some::Component < Matestack::Ui::Component

  optional :foo

  def response
    div id: "my-component" do
      plain self.text # because such an argument is almost always a string
      # or
      plain context.text # for compatibility with older releases
      plain context.foo
    end
  end

end
```

## Yielding inside components

Components can yield a block with access to scope, where a block is defined.

```ruby
class SomeComponent < Matestack::Ui::Component

  def response
    div id: "my-component" do
      yield
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
      SomeComponent.() do
        plain @foo
      end
    end
  end

end
```

Not a fancy example, but this is the result:

```markup
<div id="div-on-page">
  <div id="my-component">
    foo from page
  </div>
</div>
```

## Slots

Slots in Matestack allow us to inject whole UI snippets into the component. It's a more specific yielding mechanism as you will yield multiple "named blocks" into the component. Each of these blocks can be referenced and positioned independently in the component,

### Slots on the page instance scope

Define the slots within the component file as shown below. Please make sure to inject slots within a hash `slots: { ... }` into the component.

```ruby
class SomeComponent < Matestack::Ui::Component

  def prepare
    @foo = "foo from component"
  end

  def response
    div id: "my-component" do
      slot :my_first_slot
      br
      slot :my_second_slot
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
        my_first_slot: method(:my_simple_slot),
        my_second_slot: method(:my_second_simple_slot)
      }
    end
  end

  def my_simple_slot
    span id: "my_simple_slot" do
      plain "some content"
    end
  end

  def my_second_simple_slot
    span id: "my_simple_slot" do
      plain @foo
    end
  end

end
```

This gets rendered into HTML as shown below. Notice that the `@foo` from the component configuration got overwritten by the page's local `@foo`!

```markup
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

To use _component instance scope slots_, first define slots within a static component:

```ruby
class Other::Component < Matestack::Ui::Component

  def prepare
    @foo = "foo from other component"
  end

  def response
    div id: "my-other-component" do
      slot :my_slot_from_component
      br
      slot :my_slot_from_page
      br
      plain @foo
    end
  end

end
```

and also in some component:

```ruby
class Some::Component < Matestack::Ui::Component

  def prepare
    @foo = "foo from component"
  end

  def response
    div id: "my-component" do
      other_component slots: {
        my_slot_from_component: method(:my_slot_from_component),
        my_slot_from_page: slots[:my_slot_from_page]
      }
    end
  end

  def my_slot_from_component
    span id: "my-slot-from-component" do
      plain @foo
    end
  end

end
```

Then, put both components \(note that some component uses other component so that's how they're both in here\) to use on the example page:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @foo = "foo from page"
  end

  def response
    div id: "page-div" do
      some_component slots: { my_slot_from_page: method(:my_slot_from_page) }
    end
  end

  def my_slot_from_page
    span id: "my-slot-from-page" do
      plain @foo
    end
  end

end
```

This gets rendered into the HTML below:

```markup
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

### Calling slots with params

Sometimes it's necessary to call a slot with params:

```ruby
class SomeComponent < Matestack::Ui::Component

  def response
    div id: "my-component" do
      User.last(10).each do |user|
        slot(:user_card, user)
      end
    end
  end

end
```

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    div do
      some_component slots: {
        user_card: method(:user_card)
      }
    end
  end

  def user_card user
    div class: "card" do
      plain user.name
    end
  end

end
```

