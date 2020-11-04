[![Specs](https://github.com/matestack/matestack-ui-core/workflows/specs/badge.svg)](https://github.com/matestack/matestack-ui-core/actions)
[![Discord](https://img.shields.io/discord/771413294136426496.svg)](https://discord.gg/c6tQxF)
[![Gem Version](https://badge.fury.io/rb/matestack-ui-core.svg)](https://badge.fury.io/rb/matestack-ui-core)
[![Docs](https://img.shields.io/badge/docs-matestack-blue.svg)](https://docs.matestack.io)
[![Twitter Follow](https://img.shields.io/twitter/follow/matestack.svg?style=social)](https://twitter.com/matestack)

![matestack logo](./logo.png)

# matestack-ui-core | UI in pure Ruby

Boost your productivity & easily create component based web UIs in pure Ruby.
Reactivity included if desired.

`matestack-ui-core` enables you to craft maintainable web UIs in pure Ruby, skipping ERB and HTML. UI code becomes a native and fun part of your Rails app. Thanks to reactive core components, reactivity can be optionally added on top without writing JavaScript, just using a simple Ruby DSL.

You end up writing 50% less code while increasing productivity, maintainability and developer happiness. Work with pure Ruby. If necessary, extend with pure JavaScript. No Opal involved.

The main goals are:

- More maintainable UI code, using a component-based structure written in Ruby
- Increased development speed and happiness, offering prebuilt UI-Components for typical requirements
- Modern, dynamic UI feeling without the need to implement a separate JavaScript Application

`matestack-ui-core` can progressively replace the classic Rails-View-Layer. You are able to use
it alongside your classic views and incrementally turn your Rails-App into a
dynamic Web-App.

## Documentation/Installation

Documentation can be found [here](https://docs.matestack.io)

## Changelog

Changelog can be found [here](./CHANGELOG.md)

## Community

As a low-barrier feedback channel for our early users, we have set up a Discord server that can be found [here](https://discord.gg/c6tQxF). You are very welcome to ask questions and send us feedback there!

## Contribution

We are happy to accept contributors of any kind. Please refer to the [Contribution Guide](https://docs.matestack.io/docs/start/400-contribute/README.md)

## Features

On our [landingpage](https://www.matestack.io), we're presenting the following features alongside some live demos!


### 1. Create UI components in pure Ruby

Craft your UI based on your components written in pure Ruby. Utilizing Ruby's amazing language features, you're able to create a cleaner and more maintainable UI implementation.

#### Implement UI components in pure Ruby

Create Ruby classes within your Rails project and call matestack's core components through a Ruby DSL in order to craft your UIs.
The Ruby method \"div\" for example calls one of the static core components, responsible for rendering HTML tags. A component can take Strings, Integers Symbols, Arrays or Hashes (...) as optional properties (e.g. \"title\") or require them (e.g. \"body\").

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      div class: "card-body" do
        heading size: 5, text: title if title.present?
        paragraph class: "card-text", text: body
      end
    end
  end

end

```

#### Use your Ruby UI components on your existing Rails views

Register your Ruby UI component classes with your desired DSL method and use the \"matestack_component\" helper in order to render your component within existing ERB views or Rails controllers.
The Ruby method \"card\" for example calls your \"Card\" class, enabling you to create a reuseable card components, abstracting UI complexity in your ow components.

`app/views/your_view.html.erb`

```erb

<!-- some other erb markup -->
<%= matestack_component :card, title: "hello", body: "world" %>
<!-- some other erb markup -->

```

`app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    card: Components::Card,
    #...
  )

end
```


#### Use Ruby methods as partials

Split your UI implementation into multiple small chunks helping others (and yourself) to better understand your implementation.
Using this approach helps you to create a clean, readable and maintainable codebase.

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image
  optional :footer

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      card_content
      card_footer if footer.present?
    end
  end

  def card_content
    div class: "card-body" do
      heading size: 5, text: title if title.present?
      paragraph class: "card-text", text: body
    end
  end

  def card_footer
    div class: "card-footer text-muted" do
      plain footer
    end
  end

end

```

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= matestack_component :card, title: "hello", body: "world", footer: "foo" %>
<!-- some other erb markup -->
```


#### Use class inheritance

Because it's just a Ruby class, you can use class inheritance in order to further improve the quality of your UI implementation.
Class inheritance can be used to easily create variants of UI components but still reuse parts of the implementation.

`app/matestack/components/blue_card.rb`

```ruby

class Components::BlueCard < Components::Card

  def response
    div class: "card shadow-sm border-0 bg-primary text-white" do
      img path: image, class: "w-100" if image.present?
      card_content #defined in parent class
      card_footer if footer.present? #defined in parent class
    end
  end

end

```

`app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    blue_card: Components::BlueCard,
    #...
  )

end
```

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= matestack_component :blue_card, title: "hello", body: "world" %>
<!-- some other erb markup -->
```

#### Use components within components

Just like you used matestack's core components on your own UI component, you can use your own UI components within other custom UI components.
You decide when using a Ruby method partial should be replaced by another self contained UI component!

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      # calling the CardBody component rather than using Ruby method partials
      card_body title: title, body: body
    end
  end

end

```
`app/matestack/components/card_body.rb`

```ruby

class Components::CardBody < Matestack::Ui::Component

  requires :body
  optional :title

  def response
    # Just an example. Would make more sense, if this component had
    # a more complex structure
    div class: "card-body" do
      heading size: 5, text: title if title.present?
      paragraph class: "card-text", text: body
    end
  end

end

```


`app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    card: Components::Card,
    card_body: Components::CardBody,
    #...
  )

end
```

#### Yield components into components

Sometimes it's not enough to just pass simple data into a component. No worries! You can just yield a block into your components!
Using this approach gives you more flexibility when using your UI components. Ofcourse yielding can be used alongside passing in simple params.


`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      card_body do
        # yielding a block into the card_body component
        heading size: 5, text: title if title.present?
        paragraph class: "card-text", text: body
      end
    end
  end

end

```

`app/matestack/components/card_body.rb`

```ruby

class Components::CardBody < Matestack::Ui::Component

  def response
    # Just an example. Would make more sense, if this component had
    # a more complex structure
    div class: "card-body" do
      yield_components
    end
  end

end

```

#### Use named slots for advanced content injection

If you need to inject multiple blocks into your UI component, you can use \"slots\"!
Slots help you to build complex UI components with multiple named content placeholders for highest implementation flexibility!

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  requires :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: image, class: "w-100" if image.present?
      card_body slots: { heading: heading_slot, body: body_slot }
    end
  end

  def heading_slot
    slot do
      heading size: 5, text: title if title.present?
    end
  end
  
  def body_slot
    slot do
      paragraph class: "card-text", text: body
    end
  end

end

```
`app/matestack/components/card_body.rb`

```ruby

class Components::CardBody < Matestack::Ui::Component

  requires :slots

  def response
    # Just an example. Would make more sense, if this component had
    # a more complex structure
    div class: "card-body" do
      div class: "heading-section" do
        slot slots[:heading]
      end
      div class: "body-section" do
        slot slots[:body]
      end
    end
  end

end

```


### 2. Use reactive UI components in pure Ruby

What about going even one step further and implement REACTIVE UIs in pure Ruby? Matestack's reactive core components can be used with a simple Ruby DSL enabling you to create reactive UIs without touching JavaScript!    

#### Toggle parts of the UI based on events

Matestack offers an event hub. Reactive components can emit and receive events through this event hub. \"onclick\" and \"toggle\" calling two of these reactive core components.
\"onclick\" emits an event which causes the body of the \"toggle\" component to be visible for 5 seconds in this example.

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def response
    onclick emit: "some_event" do
      button text: "click me"
    end
    toggle show_on: "some_event", hide_after: 5000 do
      plain "Oh yes! You clicked me!"
    end
  end

end

```

#### Call controller actions without JavaScript

Core components offer basic dynamic behaviour and let you easily call controller actions and react to server responses on the client side without full page reload.
The \"action\" component is configured to emit an event after successfully performed an HTTP request against a Rails controller action, which is receive by the \"toggle\" component, displaying the success message.

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def response
    action my_action_config do
      button text: "click me"
    end
    toggle show_on: "some_event", hide_after: 5000 do
      plain "Success!"
    end
  end

  def my_action_config
    {
      path: some_rails_route_path,
      method: :post,
      success: {
        emit: "some_event"
      }
    }
  end

end

```


### Dynamically handle form input without JavaScript

Create dynamic forms for ActiveRecord Models (or plain objects) and display server side responses, like validation errors or success messages, without relying on a full page reload.
Events emitted by the \"form\" component can be used to toggle parts of the UI.

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def prepare
    @new_active_record_instance = MyActiveRecordModel.new
  end

  def response
    form my_form_config do
      form_input key: :some_attribute, type: :text
      form_submit do
        button text: "click me"
      end
    end
    toggle show_on: "submitted", hide_after: 5000 do
      span class: "message success" do
        plain "created successfully"
      end
    end
    toggle show_on: "failed", hide_after: 5000 do
      span class: "message failure" do
        plain "data was not saved, please check form"
      end
    end
  end

  def my_form_config
    {
      for: @new_active_record_instance,
      path: some_rails_route_path,
      method: :post,
      success: {
        emit: "submitted"
      },
      failure: {
        emit: "failed"
      }
    }
  end

end

```

#### Implement asynchronous, event-based UI rerendering in pure Ruby

Using matestack's built-in event system, you can rerender parts of the UI on client side events, such as form or action submissions. Even server side events pushed via ActionCable may be received!
The \"async\" component requests a new version of its body at the server via an HTTP GET request after receiving the configured event. After successfu server response, the DOM of the \"async\" component gets updated. Everything else stays untouched.

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def response
    form my_form_config do
      #...
    end
    #...
    async rerender_on: "submitted", id: "my-model-list" do
      ul do
        MyActiveRecordModel.last(5).each do |model|
          li text: model.some_attribute
        end
      end
    end
  end

  def my_form_config
    {
      #...
      success: {
        emit: "submitted"
      },
      failure: {
        emit: "failed"
      }
    }
  end

end

```

#### Manipulate parts of the UI via ActionCable

\"async\" rerenders its whole body - but what about just appending the element to the list after successful form submission?
The \"cable\" component can be configured to receive events and data pushed via ActionCable from the server side and just append/prepend new chunks of HTM (ideally rendered through a component) to the current \"cable\" component body. Updating and deleting is also supported!

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def response
    form my_form_config do
      #...
    end
    #...
    ul do
      cable prepend_on: "new_element_created", id: "mocked-instance-list" do
        MyActiveRecordModel.last(5).each do |model|
          li text: model
        end
      end
    end
  end

end

```

`app/controllers/some_controller.rb`

```ruby
# within your controller action handling the form input
ActionCable.server.broadcast("matestack_ui_core", {
  event: "new_element_created",
  data: matestack_component(:li, text: params[:some_attribute])
})

```

#### Easily extend with Vue.js

Matestack's dynamic parts are built on Vue.js. If you want to implement custom dynamic behaviour, you can simply create your own Vue components and use them along matestacks core components.
It's even possible to interact with matestack's core components using the built-in event bus.

`app/matestack/components/some_component.rb`

```ruby

class Components::SomeComponent < Matestack::Ui::Component

  def response
    my_vue_js_component
    toggle show_on: "some_event", hide_after: "3000" do
      span class: "message success" do
        plain "event triggered from custom vuejs component"
      end
    end
  end

end

```
`app/matestack/components/my_vue_js_component.rb`

```ruby
class Components::MyVueJsComponent < Matestack::Ui::VueJsComponent

  vue_js_component_name "my-vue-js-component"

  def response
    div class: "my-vue-js-component" do
      button attributes: {"@click": "increaseValue"}
      br
      plain "{{ dynamicValue }}!"
    end
  end

end
```

`app/matestack/components/my_vue_js_component.js`

```javascript
MatestackUiCore.Vue.component('my-vue-js-component', {
  mixins: [MatestackUiCore.componentMixin],
  data: () => {
    return {
      dynamicValue: 0
    };
  },
  methods: {
    increaseValue(){
      this.dynamicValue++
      MatestackUiCore.matestackEventHub.$emit("some_event")
    }
  }
});
```

### 3. Create whole SPA-like apps in pure Ruby

The last step in order to leverage the full Matestack power: Create app (~Rails layout) and page (Rails ~view) classes and implement dynamic page transitions without any JavaScript implementation required.

#### Create your layouts and views in pure Ruby

The app class is used to define a layout, usually containing some kind of header, footer and navigation. The page class is used to define a view. Following the same principles as seen on components, you can use components (core or your own) in order to create the UI.
The \"transition\" component enables dynamic page transition, replacing the content within \"yield_page\" with new serverside rendered content.

`app/matestack/some_app/app.rb`

```ruby

class SomeApp::App < Matestack::Ui::App

  def response
    nav do
      transition path: page1_path do
        button text: "Page 1"
      end
      transition path: page2_path do
        button text: "Page 2"
      end
    end
    main do
      div class: "container" do
        yield_page
      end
    end
  end

end

```

`app/matestack/some_app/pages/page1.rb`

```ruby
class SomeApp::Pages::Page1 < Matestack::Ui::Page

  def response
    div class: "row" do
      div class: "col" do
        plain "Page 1"
      end
    end
  end

end

```

`app/matestack/some_app/pages/page2.rb`

```ruby
class SomeApp::Pages::Page2 < Matestack::Ui::Page

  def response
    div class: "row" do
      div class: "col" do
        plain "Page 2"
      end
    end
  end

end

```

#### Apps and pages are referenced in your Rails controllers and actions

Instead of referencing Rails layouts and views on your controllers, you just use apps and pages as substitutes.
Work with controllers, actions and routing as you're used to! Controller hooks (e.g. devise's authenticate_user) would still work!

`app/controllers/some_controller.rb`

```ruby

class SomeController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry

  matestack_app SomeApp::App

  def page1
    render SomeApp::Page1
  end

  def page2
    render SomeApp::Page2
  end

end

```

`app/config/routes.rb`

```ruby
Rails.application.routes.draw do

  root to: 'some#page1'

  get :page1, to: 'some#page1'
  get :page2, to: 'some#page2'

end

```

#### Use CSS animations for fancy page transition animations

Use matestack's css classes applied to the wrapping DOM structure of a page in order to add CSS animiations, whenever a page transition is performed."
You can even inject a loading state element, enriching your page transition effect.

`app/matestack/some_app/app.rb`

```ruby

class SomeApp::App < Matestack::Ui::App

  def response
    nav do
      transition path: page1_path do
        button text: "Page 1"
      end
      transition path: page2_path do
        button text: "Page 2"
      end
    end
    main do
      div class: "container" do
        yield_page slots: { loading_state: loading_state_element }
      end
    end
  end

  def loading_state_element
    slot do
      div class: 'some-loading-element-styles'
    end
  end

end

```

`app/assets/stylesheets/application.scss`

```scss

.matestack-page-container{

  .matestack-page-wrapper {
    opacity: 1;
    transition: opacity 0.2s ease-in-out;

    &.loading {
      opacity: 0;
    }
  }

  .loading-state-element-wrapper{
    opacity: 0;
    transition: opacity 0.3s ease-in-out;

    &.loading {
      opacity: 1;
    }
  }

}

```

## License
matestack-ui-core is an Open Source project licensed under the terms of the [LGPLv3 license](./LICENSE)
