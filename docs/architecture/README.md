# Architecture

In this section, we take a deep dive into how Matestack is implemented.

**The Matestack core was developed while iterating concepts following the main goal of `just making it work`. Therefore, the core is not yet well engineered in some places. After we were happy with it working, we've spent quite some time writing tests to save the status quo, and now we're about to refactor the core.**

Please refer to the [detailed architectural drawing](/docs/architecture/matestack_rendering.png) while reading the following documentation.

## Example

In order to better understand the core architecture, we will often refer to the following example code:

Our App: `app/matestack/apps/my_app.rb`

```ruby
class Apps::MyApp < Matestack::Ui::App

  def response
    components{
      header do
        heading size: 1, text: "My App"
      end
      nav do
        transition path: :some_rails_route do
          button text: "Page 1"
        end
        transition path: :some_other_rails_route do
          button text: "Page 2"
        end
      end
      main do
        page_content
      end
      footer do
        plain "some text"
      end
    }
  end

end
```

Our first Page: `app/matestack/pages/my_app/my_first_page.rb`

```ruby
class Pages::MyApp::MyFirstPage < Matestack::Ui::Page

  def response
    components{
      div id: "foo", class: "bar" do
        plain "Page 1"
      end
    }
  end

end
```

Our second Page: `app/matestack/pages/my_app/my_second_page.rb`

```ruby
class Pages::MyApp::MySecondPage < Matestack::Ui::Page

  def response
    components{
      div id: "foo", class: "bar" do
        plain "Page 2"
      end
    }
  end

end
```

## Prerequisites

### Trailblazer Cell

Matestacks Pages, Components and Apps all inherit from their respective base classes. These classes themselves inherit from [Trailblazers Cell](https://github.com/trailblazer/cells).

Alongside many other advantages, this gives us the basic building blocks to render Ruby into HTML. Trailblazers Cells encourage you to create a Ruby class and a corresponding view template. Within this template, you may call methods which are defined in the Cell and even nest more Cells.

The Cell parses the template, executes Ruby methods and optionally calls the nested Cells rendering and finally returns an HTML string. The result is a serverside rendered static HTML output, just like what you would have got with classic Rails ERB/HAML/Slim. But with Trailblazers cells, you truly encapsulated parts of the UI (making them test- and reusable) and don't just build one big template.

Matestacks core is built on top of this rendering approach.

## Matestack Responder

In order to enable Matestack rendering, the `responder_for` helper is used within a Rails controller action. This helper awaits a Page Cell class as first parameter. On every request, the helper instantiates the assigned Page Cell class and calls `show` on the created instance.

## Page Cell

### Instantiation

The constructor of a Page Cell triggers following processes:

#### Prepare

If a prepare method is defined, the method gets executed first. It might be used to set instance variables, which can be used later on.

#### Response

A Page Cell class always has a response method which gets called from the constructor. This methods defines the UI of the page orchestrating components.

##### Nodes

The `components` method within the `response` method calls the `Node Builder` with a block as an argument. The `Node Builder` then generates the `@nodes` hash which represents all used Components.

- --> [Node Builder](#node-builder)

##### Cells

Each **top level** key of `@nodes` needs to be translated to a Component Cell instance

**a) lookup**

In order to find the corresponding Cell class `ToCell` is used:

- --> [Component Lookup](#component-lookup)

**b) instantiation**

If a Cell class is found, a new instance of this class is created:

- --> [Component Instantiation](#component-instantiation)

All top-level nodes of a Page gets translated to a corresponding Component Cell instance and stored in `@cells`

**Note**

It is important to understand where and when Cell instantiation is happening:

1. a page Cell (like `Pages::MyApp::MyFirstPage`) gets instantiated when `responder_for(Pages::MyApp::MyFirstPage)` is called within a controller action
2. the page Cell instance then instantiates all top-level nodes defined in its response method (in this case `div`)
3. all now instantiated top-level cells from page, instantiate their top-level nodes if present (in this case, `div` instantiates `plain` as its single top-level node)
4. and so on (in our example we're done, but it could go on like this)

As we can see, a Page doesn't instantiate all components defined in its response method itself. It only takes care of its top-level nodes. That's why in our example the instance variable `@cells` of `Pages::MyPage` only contains a reference to the instance of `Div::Div` and `@cells` of the instance `Div::Div` only contains a reference to the instance of `Plain::Plain`


### Page Rendering

After a Page Cell is instantiated, it can be rendered to HTML. The `show` method of a Page Cell instance renders the Page depending on which `render_mode` is requested:

**a) with_app**

This `render_mode` applies if ALL of the following conditions are met:

- Initial page load
  - the browser requests the route directly
- Page Cell is related to an App Cell
  - if the second module within the namespace of the Page Cell reflects an App
  - --> `Pages::MyApp::MyFirstPage` --> `MyApp` is second module and reflects an App class
  - --> `Pages::MyFirstPage` --> `MyFirstPage` is second module and does NOT reflect an App class

If both conditions are met, the response needs to include the Page HTML wrapped by the App layout HTML.
The Page Rendering is therefore delegated to the corresponding App Cell instance. The App Cell instance gets created through injecting the `@nodes` of the Page Cell instance into the constructor of the App Cell:

- --> [App Instantiation](#app-instantiation)
- --> [App Rendering](#app-rendering)

**b) only_page**

This `render_mode` applies if ONE OF the following conditions is met:

- Explicit `only_page` request
  - the page is requested with the query param: `only_page=true`
  - (these requests are used for dynamic transitions)
- Page Cell is NOT related to an App Cell
  - --> `Pages::MyFirstPage` --> not related to an App Cell

If one of the conditions is met, the page.haml template is used to add `div`-wrapper:

```HAML
%div{class: "matestack_page_content"}
  - @cells.each do |key, cell|
    = cell.call(:show)
```

The Page then iterates through all Component Cell instances stored in `@cells`, calls show on each of them and renders their response to HTML.

- --> [Component Rendering](#component-rendering)

**c) only_component**

This `render_mode` applies if the following condition is met:

- Explicit request for **exactly one** component:
  - the page is requested with the query param: `component_key=xyz`

If the Page is asked to only render one of its Components, the given `component_key` is used to find the corresponding node within the Pages `@nodes`. If found, the corresponding Component Cell is instantiated and ONLY this Cell is rendered:

- --> [Component Lookup](#component-lookup)
- --> [Component Instantiation](#component-instantiation)
- --> [Component Rendering](#component-rendering)

## Component Cell

### Component Lookup

Whenever `ToCell` is used to transform a node into a Cell, the corresponding Cell class is looked up in following order:

1. custom components inside the projects `app/matestack/components` folder if component name is prefixed with "custom_"
2. core components inside matestacks own `app/concepts/matestack/ui/core` folder
3. add-on components defined in other engines if no core component is found

While looking for the Cell classes, `ToCell` translates the string based component names (e.g. "form") to a class name following these rules:

no namespace (underscore) used:
- `form` gets translated to `Matestack::Ui::Core::Form::Form`
- `someComponent` gets translated to `Matestack::Ui::Core::SomeComponent::SomeComponent`

(Parent module and Cell class name are expected to be the same)

namespace (underscore) used:
- `form_input` gets translated to `Matestack::Ui::Core::Form::Input::Input`
- `someNamespace_someComponent` gets translated to `Matestack::Ui::Core::SomeNamespace::SomeComponent::SomeComponent`

(Parent module and Cell class names are not expected to be the same)

custom prefixed used;
- `custom_component` gets translated to `Components::Component`
- `custom_namespaced_component` gets translated to `Components::Namespaced::Component`
- `custom_namespaced_someComponent` gets translated to `Components::Namespaced::SomeComponent`

(parent module is `Components` as custom components live inside the `components` folder)

### Component Instantiation

The constructor of a Component Cell triggers following processes:

#### Prepare

If a prepare method is defined, the method gets executed. It might be used to set some instance variables, which can be used later on.

#### Response

In contrast to a Page Cell class, a Component Cell class optionally may have a response method which gets called from the constructor. This methods can be used to orchestrate other Components.

**Note**

It is important to realize that all basic core Components (div, span, ul, li etc...) **do not** use a response method to define their UI. They just use a template file as described here:

- --> [Component Rendering](#component-rendering)

#### Nodes

If defined, the response function calls the components method, which will generate `@nodes` as described here:

- --> [Node Builder](#node-builder)

#### Cells

This process essentially works as described at the Page Cell section.

Each **top level** key of `@nodes` needs to be translated to a Component Cell instance

**a) lookup**

In order to find the corresponding Cell class `ToCell` is used:

- --> [Component Lookup](#component-lookup)

**b) instantiation**

If a Cell class is found, a new instance of this class is created:

- --> [Component Instantiation](#component-instantiation)

All top-level nodes of a Component get translated to a corresponding Component Cell instance and stored in `@cells`.

#### Children Cells

In contrast to a Page or an App, a Component may be called with a block:

```ruby
class Pages::MyApp::MyFirstPage < Matestack::Ui::Page

  def response
    components{

      div id: "foo", class: "bar" do
        plain "Page 1" #div called with a block
      end

    }
  end

end
```

As you can see in this example, the `div` Component is called with a block including the `plain` Component call. Under the hood, the Page Cell generates following `@nodes` hash out of the example's `response`:

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
        "argument"=>"Page 1"
      }
    }
  }
}
```

The Page Cell then iterates through all top-level nodes and calls the `to_cell` process for each node and injects the corresponding value hash, which means that our `div` gets instatiated with the value hash:

```ruby
{
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
      "argument"=>"Page 1"
    }
  }
}
```

including the `components` key with the value hash

```ruby
{
   "plain_1"=>{
     "component_name"=>"plain",
     "config"=>{},
     "included_config"=>nil,
     "argument"=>"Page 1"
    }
}
```

For each top-level node of this hash, the Component Cell calls the same `to_cell` process, as the Page Cell did for all of its top-level nodes. The resulting Cell instances are stored in `@children_cells` of the created Component Cell instance. (In this case, it's only the `plain` Cell instance)

A Component Cell instance may end up with two sets of Cells:

- `@cells` if the Component used a `response` method in order to define its UI
- `@children_cells` if the Component was called with a block from the parent level (Page Cell in this example)

As described in following section, those two sets of Cells are rendered differently.

### Component Rendering

#### Render Mode

A Components UI may be defined in a response method OR just in a template file. It is important to realize that all basic core Components (div, span, ul, li etc...) don't use a response method to define their UI. Each of them just uses a simple template file. We recommend to use response methods in all custom Components, as only very basic Components should use a template file.

**a) response method**

If a `response` method is used, the Component will iterate `@cells` using a basic component template file. Depending on whether the Component is `static` or `dynamic`, the corresponding template looks differently:

**i) static**

```haml
- @cells.each do |key, cell|
  = cell.call(:show)
```

**ii) dynamic**

```haml
%component{dynamic_tag_attributes}
  - @cells.each do |key, cell|
    = cell.call(:show)
```

The Cells get wrapped by a `component` tag. `dynamic_tag_attributes` returns a hash, defining the attributes of that tag:

```ruby
{
  "is": @component_class,
  "ref": component_id,
  ":params":  @url_params.to_json,
  ":component-config": @component_config.to_json,
  "inline-template": true,
}
```

- `"is": @component_class` is used to reference the corresponding Vue.js components
  - example: the dynamic core Component `transition` has a corresponding Vue.js component named "transition-cell", which is also the value of `@component_class` in this case
- `"ref": component_id` may be used to identify the specific instance of this Component on one Page
- `:params":  @url_params.to_json` is used to pass request params to the Vue.js Component instance
- `":component-config": @component_config.to_json` is used to pass configuration to the Vue.js Component instance
  - this is very useful if a Vue.js component relies on meta data to perfom its desired behaviour during runtime
  - example: the dynamic core Component `transition` gets a `path` config when used in a `response` method. As the value is just a symbol referencing a rails route, the Component needs to translate the symbol to a string on the server-side. This string is then added to the `@component_config` and parsed by the `transition` Vue.js component instance during browser runtime
- `"inline-template": true` needs to be set in order to tell Vue.js that this component uses the server-side rendered markup as template.

**b) template file**

Instead of a `response` method, a Components' UI may be defined by a template file. The `div` Component for example is defined by:

```HAML
%div{@tag_attributes}
  - if block_given?
    = yield
```

This template may be wrapped by a core template, depending on whether the Component is `static` or `dynamic`:

**i) static**

If the Component is static, it doesn't get wrapped and just renders the component specific template. This is done by rendering a core component template:

```HAML
= render_content
```

`render_content` calls Trailblazers `render` method with a block. This block contains the rendering of the `@children_cells` done via another core component template:

```HAML
- @children_cells.each do |key, cell|
  = cell.call(:show)
```

This `@children_cells` rendering may then be used in the component specific template file in order to yield `@children_cells` on the desired position:

```HAML
%div{@tag_attributes}
  - if block_given?
    = yield # @children_cells gets yielded here
```

**ii) dynamic**

If the Component is dynamic, the same principles as above apply, except for an additional wrapping of the Component markup in the first step:

```HAML
%component{dynamic_tag_attributes}
  = render_content
```

## App Cell

### App Instantiation

The constructor of an App Cell triggers following processes. In contrast to Page or Component, the App relies on a special parameter when instantiated: A Page Instance injects its own `@nodes` into the constructor of the App Cell class:

- --> [Page Rendering](#page-rendering) --> a)

#### Prepare

If a prepare method is defined, the method gets executed. It might be used to set some instance variables, which can be used later on.

#### Response

An App Cell class always has a response method which gets called from the constructor. This method defines the UI of the App orchestrating components.

##### Nodes

The `components` method within the `response` method calls the `Node Builder` with a block. The `Node Builder` then generates the `@nodes` hash which represents all used Components.

- --> [Node Builder](#node-builder)

The injected `@page_nodes` are added when `page_content` is used within the Apps `response` method

- --> [App Node](#app-node)

##### Cells

Each **top level** key of `@nodes` needs to be translated to a Component Cell instance

**a) lookup**

In order to find the corresponding Cell class `ToCell` is used:

- --> [Component Lookup](#component-lookup)

**b) instantiation**

If a Cell class is found, a new instance of this class is created:

- --> [Component Instantiation](#component-instantiation)

All top-level nodes of an App get translated to a corresponding Component Cell instance and stored in `@cells`

### App Rendering

The Apps response is rendered using the app template:

```HAML
%component{"is": "app-cell", "inline-template": true}
  %div{"class": "matestack_app"}
    - @cells.each do |key, cell|
      = cell.call(:show)
```

The template adds the App's Vue.js Component reference and a single wrapping div and then iterates through all `@cells` and renders their response.

#### Page Content Component

As described, all `@page_nodes` gets inserted into the `@nodes` of an App when `page_content` is called within the `response` method of an App. Under the hood, the App uses the dynamic core Component `page_content` in order to render these `@page_nodes`.

#### Page Content Vue Component

TODO

### App Vue Component

TODO

## Node Builder

### General

The input of a `Node Builder` is a block consisting of method calls:

```ruby
#...
div id: "foo", class: "bar" do
  plain "Hello World"
end
#...
```

The output is a ruby hash:

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

As you can see, our component block is translated to a nested Ruby hash. Every component is represented by its own hash and referenced with a key, consisting of the component name followed by a number 1..n (starting from 1 on each nesting level). Inside this component hash, you find various meta information.

Every time you use a Ruby block, a new nested "components" hash is added to the parent component hash (div_1 -> components -> plain_1)

### Method Missing Approach

TODO

### App Node

TODO

#### Partials

TODO

#### Page Content

TODO

### Page Node

TODO

#### Partials

TODO

### Component Node

TODO

#### Partials

TODO

#### Slots

TODO

#### Yield

TODO
