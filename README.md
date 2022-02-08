[![Specs](https://github.com/matestack/matestack-ui-core/workflows/specs/badge.svg)](https://github.com/matestack/matestack-ui-core/actions)
[![Discord](https://img.shields.io/discord/771413294136426496.svg)](https://discord.com/invite/c6tQxFG)
[![Gem Version](https://badge.fury.io/rb/matestack-ui-core.svg)](https://badge.fury.io/rb/matestack-ui-core)
[![Docs](https://img.shields.io/badge/docs-matestack-blue.svg)](https://docs.matestack.io)
[![Twitter Follow](https://img.shields.io/twitter/follow/matestack.svg?style=social)](https://twitter.com/matestack)

![matestack logo](./logo.png)

# matestack-ui-core | UI in pure Ruby

Boost your productivity & easily create component based web UIs in pure Ruby.

`matestack-ui-core` enables you to craft maintainable web UIs in pure Ruby, skipping ERB and HTML. UI code becomes a native and fun part of your Rails app.

`matestack-ui-core` can progressively replace the classic Rails-View-Layer. You are able to use
it alongside your classic views.

## Compatibility

### Ruby/Rails

`matestack-ui-core` is tested against:

- Rails 7.0.1 + Ruby 3.0.0
- Rails 6.1.1 + Ruby 3.0.0
- Rails 6.1.1 + Ruby 2.7.2
- Rails 6.0.3.4 + Ruby 2.6.6
- Rails 5.2.4.4 + Ruby 2.6.6

Rails versions below 5.2 are not supported.

## Documentation/Installation

Documentation can be found [here](https://docs.matestack.io/matestack-ui-core)

## Getting started

A getting started guide can be found [here](https://docs.matestack.io/matestack-ui-core/getting-started/quick-start)

## Changelog

Changelog can be found [here](./CHANGELOG.md)

## Community

As a low-barrier feedback channel for our early users, we have set up a Discord server that can be found [here](https://discord.com/invite/c6tQxFG). You are very welcome to ask questions and send us feedback there!

## Contribution

We are happy to accept contributors of any kind! In order to make it as easy and fun as possible to contribute to `matestack-ui-core`, we would like to onboard contributors personally! Best way to become a contributor: Ping us on Discord! We will schedule a video call with you and show you, how and what to work on :)

## Features

### 1. Create UI components in pure Ruby

Craft your UI based on your components written in pure Ruby. Utilizing Ruby's amazing language features, you're able to create a cleaner and more maintainable UI implementation.

#### Implement UI components in pure Ruby

Create Ruby classes within your Rails project and call matestack's core components through a Ruby DSL in order to craft your UIs.
The Ruby method \"div\" for example calls one of the static core components, responsible for rendering HTML tags. A component can take Strings, Integers Symbols, Arrays or Hashes (...) as optional properties (e.g. \"title\") or require them (e.g. \"body\").

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  required :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      div class: "card-body" do
        h5 context.title if context.title.present?
        paragraph context.body, class: "card-text"
      end
    end
  end

end

```

#### Use your Ruby UI components on your existing Rails views

Components can be then called on Rails views (not only! see below), enabling you to create a reusable card components, abstracting UI complexity in your own components.

`app/views/your_view.html.erb`

```erb

<!-- some other erb markup -->
<%= Components::Card.call(title: "hello", body: "world") %>
<!-- some other erb markup -->

```


#### Use Ruby methods as partials

Split your UI implementation into multiple small chunks helping others (and yourself) to better understand your implementation.
Using this approach helps you to create a clean, readable and maintainable codebase.

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  required :body
  optional :title
  optional :image
  optional :footer

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      card_content
      card_footer if context.footer.present?
    end
  end

  def card_content
    div class: "card-body" do
      h5 context.title if context.title.present?
      paragraph context.body, class: "card-body"
    end
  end

  def card_footer
    div class: "card-footer text-muted" do
      plain context.footer
    end
  end

end

```

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= Components::Card.call(title: "hello", body: "world", footer: "foo") %>
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
      img path: context.image, class: "w-100" if context.image.present?
      card_content #defined in parent class
      card_footer if context.footer.present? #defined in parent class
    end
  end

end

```

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= Components::BlueCard.call(title: "hello", body: "world") %>
<!-- some other erb markup -->
```

#### Use components within components

Just like you used matestack's core components on your own UI component, you can use your own UI components within other custom UI components.
You decide when using a Ruby method partial should be replaced by another self contained UI component!

`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  required :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      # calling the CardBody component rather than using Ruby method partials
      Components::CardBody.call(title: context.title, body: context.body)
    end
  end

end

```
`app/matestack/components/card_body.rb`

```ruby

class Components::CardBody < Matestack::Ui::Component

  required :body
  optional :title

  def response
    # Just an example. Would make more sense, if this component had
    # a more complex structure
    div class: "card-body" do
      h5 context.title if context.title.present?
      paragraph context.body, class: "card-body"
    end
  end

end

```


#### Yield components into components

Sometimes it's not enough to just pass simple data into a component. No worries! You can just yield a block into your components!
Using this approach gives you more flexibility when using your UI components. Ofcourse yielding can be used alongside passing in simple params.


`app/matestack/components/card.rb`

```ruby

class Components::Card < Matestack::Ui::Component

  required :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      Components::CardBody.call() do
        # yielding a block into the card_body component
        h5 context.title if context.title.present?
        paragraph context.body, class: "card-body"
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
      yield if block_given?
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

  required :body
  optional :title
  optional :image

  def response
    div class: "card shadow-sm border-0 bg-light" do
      img path: context.image, class: "w-100" if context.image.present?
      Components::CardBody.call(slots: {
        heading: method(:heading_slot),
        body: method(:body_slot)
      })
    end
  end

  def heading_slot
    h5 context.title if context.title.present?      
  end

  def body_slot
    paragraph context.body, class: "card-body"
  end

end

```
`app/matestack/components/card_body.rb`

```ruby

class Components::CardBody < Matestack::Ui::Component

  required :slots

  def response
    # Just an example. Would make more sense, if this component had
    # a more complex structure
    div class: "card-body" do
      div class: "heading-section" do
        slot :heading
      end
      div class: "body-section" do
        slot :body
      end
    end
  end

end

```

## License

`matestack-ui-core` is an Open Source project licensed under the terms of the [MIT license](./LICENSE)
