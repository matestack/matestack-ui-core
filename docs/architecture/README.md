# Architecture

In this section we want to show you, how Matestack actually is implemented.

## 1. How does Matestack renders Ruby to HTML?

First of all: Why did we decide to use a Ruby class in order to define our UI? Well, we just wanted to code our UI in PURE Ruby instead of using ERB/HAML/Slim. We wanted to make UI-Development a native part of our Rails Apps. It should feel like coding a model, controller or any other part of Rails.

The result:

```ruby
class Pages::MyPage < Page::Cell::Page

  def response
    components{
      div id: "foo", class: "bar" do
        plain "Hello #{just_for_fun_a_method_call}"
      end
    }
  end

  def just_for_fun_a_method_call
    "World"
  end

end
```

returns

```html
<div id="foo" class="bar">
  Hello World
</div>
```

So how does that work?

### Trailblazers Cell

Matestacks Pages, Components and Apps all inherits from base classes. These class themselves inherit from [Trailblazers Cell](https://github.com/trailblazer/cells).

Alongside with many other advantages, this gives us the basic building blocks to render Ruby into HTML. Trailblazers Cells encourage you to create a Ruby class and a corresponding view template. Within this template you may call methods which are defined in the Cell and even nest more Cells.

The Cell parses the template, executes Ruby methods and optionally calls the nested Cells rendering and finally returns an HTML string. The result is a serverside rendered static HTML output, just like what you would have got with classic Rails ERB/HAML/Slim. But with Trailblazers cells, you truly encapsulated parts of the UI and didn't build just one big template.

Within Matestacks core, we often use exactly this approach. Just have a look at the example above. Within `MyPage` we use a `div` Component. Let's have look, how this core Component is implemented:

`app/concepts/div/cell/div.rb`
```ruby
class Div::Cell::Div < Component::Cell::Static
  #nothing happens here, all relevant stuff is handled in the base class already
end
```
`app/concepts/div/view/div.haml`
```HAML
%div{@tag_attributes}
  - if block_given?
    = yield
```
`Component::Cell::Static` inherits from Trailblazers Cell and provides a lot of Matestack specific APIs (e.g. `@tag_attributes` which is a hash including class and id in this example). Besides the Matestack specific APIs, we use Trailblazers approach to define the `div` core Component.

### HAML template vs. Response method

It is important to realize that all basic core Components (div, span, ul, li etc...) rely on a corresponding HAML template following the rendering approach of Trailblazers Cell.

But: a Component may alternatively use Matestacks rendering approach using a `response` method. Custom Components, Pages and Apps all use a `response` method in order to orchestrate other components in pure Ruby. Within `MyPage` we use the `response` method in order to build the UI consisting of plain text wrapped by a div. As this is just a Ruby instance method, you can do whatever Ruby has to offer, while building your UI.

### Component Node Tree

You probably already recognized the `components { ... }` syntax within the `response` method. The `components` method is responsible for building a so called "component node tree" out of all used components.

Input is a block consisting of other component calls, like:

```ruby
#...
div id: "foo", class: "bar" do
  plain "Hello World"
end
#...
```

Output is a ruby hash, like:

```ruby
{
  "div_1"=>{
    "component_name"=>"div",
    "config"=>{
      "id"=>"foo",
      "class"=>"bar"
    },
    "included_config"=>nil,
    "argument"=>nil,
    "components"=>{
      "plain_1"=>{
        "component_name"=>"plain",
        "config"=>{},
        "included_config"=>nil,
        "argument"=>"Hello World"
      }
    }
  }
}
```
As you can see, our component block is translated to a nested Ruby hash. Every component is represented with its own hash referenced with a key consisting of the component name followed by a number 1..n (starting from 1 on each nesting level). Inside this component hash, you find various meta information.

Every time you use a Ruby block, a new nested "components" hash is added to the parent component hash (div_1 -> components -> plain_1)

### Method missing approach

TODO

### Nodes to Cells

The "Component Node Tree" hash gets parsed in order to create a Cell for each component. `Shared::Utils::ToCell` is looking for the corresponding Cell class in following order:

1. custom components inside the projects `app/matestack/components` folder if component name is prefixed with "custom_"
2. core components inside matestacks own `app/concepts` folder
3. add-on components defined in other engines if no core component is found

While looking for the Cell classes, `Shared::Utils::ToCell` translates the string based component names (e.g. "form") to a class name following these rules:

no namespace (underscore) used:
- `form` gets translated to `Form::Cell::Form`
- `someComponent` gets translated to `SomeComponent::Cell::SomeComponent`

(parent module and Cell class name are expected to be the same)

namespace (underscore) used:
- `form_input` gets translated to `Form::Cell::Input`
- `someNamespace_someComponent` gets translated to `SomeNamespace::Cell::SomeComponent`

(parent module and Cell class names are not expected to be the same)

custom prefixed used;
- `custom_component` gets translated to `Components::Component::Cell::Component`
- `custom_namespaced_component` gets translated to `Components::Namespaced::Cell::Component`
- `custom_namespaced_someComponent` gets translated to `Components::Namespaced::Cell::SomeComponent`

(parent module is `Components` as custom components live inside the `components` folder, all other rules still apply)

### Cell Instantiation

If a Cell class is found, a new instance of this class is created. The Cell configuration gets passed to Trailblazers Cell constructor which is then extended by Matestacks own constructor.

It is important to understand, where and when Cell instantiation is happening:

1. a page Cell (like `Pages::MyPage`) gets instantiated when `responder_for(Pages::MyPage)` is called within a controller action
2. the page Cell instance then instantiates all direct children defined in its response method (in this case `div`)
3. all now instantiated direct children from page, instantiate their direct children if present (in this case `div` instantiates `plain` as its direct children)
4. and so on (in our example we're done, but it could go on like this)

As we can see, a Page doesn't instantiate all components defined in its response method itself. It only takes care of its direct children. That's why in our example the instance variable `@children_cells` of `Pages::MyPage` only contains a reference to the instance of `Div::Cell::Div` and `@children_cells` of the instance `Div::Cell::Div` only contains a reference to the instance of `Plain::Cell::Plain`

### Cell Configuration

The Cell configuration which will get passed into the constructor consists of multiple data. This data basically consists of the configuration, the developer has added while creating the UI:

```ruby
#...
div id: "foo", class: "bar" do
  plain "Hello World"
end
#...
```

The configuration for the cell representing the `div` component is configured with a hash `{ id: "foo", class: "bar" }`. `plain` only gets a string `"Hello World"`.

During multiple steps these basic configurations are extended and transformed until they finally are available inside the Cell instance. `{ id: "foo", class: "bar" }` is then available as the instance variable `@options` within the `div` Cell instance (because a hash was given) and `"Hello World"` is available as the instance variable `@argument` with the `plain` Cell instance (because just one argument was given)


### Cell Children

Besides `@options` and `@argument`, a component with nested components has to take care of instantiation of their corresponding Cell classes. In the above shown example, `div` has one nested component: `plain`. That's why the Cell configuration of `Div::Cell::Div` also contains a hash called `children`, looking like:

```ruby
{
  "plain_1"=>{
    "component_name"=>"plain",
    "config"=>{},
    "included_config"=>nil,
    "argument"=>"Hello World"
  }
}
```
The constructor of `Div::Cell::Div` triggers the "Nodes To Cell" process, we already covered, based on this hash. While transforming a page node to a Cell, a component key is created. In our example `div` got the key `div_1` and `plain` got the key `div_1__plain_1`. As you can see, the component_key reflects the nesting level of a component in the context of one specific page (`Pages::MyPage` in this example). This component_key becomes very important when we will cover, how partial rerendering of a page is implemented.

### Cell Validation

### Cell Setup

### Cell Rendering

#### Page Cell Rendering

#### Component Cell Rendering


## 2. Static vs. Dynamic Components
