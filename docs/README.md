---
description: >-
  Matestack Ui Core - Boost your productivity & easily create component based
  web UIs in pure Ruby.
---

# Welcome

{% hint style="info" %}
Version 3.0.0 was released on the xth of February 2022. Click here for more [details](migrate-from-2.x-to-3.0.md)

**Most important changes:**

* Split `matestack-ui-core` into `matestack-ui-core` and `matestack-ui-vuejs`
* Rails 7 support
* Vue 3 support in `matestack-ui-vuejs`

****

**If you want to see the docs for Version 2.1, click** [**here**](https://docs.matestack.io/matestack-ui-core/v/2.1/)**:**
{% endhint %}

## **About**

`matestack-ui-core` enables you to craft maintainable, **component based** web UIs in **pure Ruby**, skipping ERB and HTML. UI code becomes a native and fun part of your Rails app. It can progressively replace the classic Rails-View-Layer. You are able to use it alongside your Rails views.

## Compatibility

`matestack-ui-core` is automatically tested against:

* Rails 7.0.1 + Ruby 3.0.0
* Rails 6.1.1 + Ruby 3.0.0
* Rails 6.1.1 + Ruby 2.7.2
* Rails 6.0.3.4 + Ruby 2.6.6
* Rails 5.2.4.4 + Ruby 2.6.6

{% hint style="danger" %}
Rails versions below 5.2 are not officially supported.
{% endhint %}

## Getting Started

Start right away and install `matestack-ui-core` on top of your Rails app, or read something about the features below.

{% content-ref url="getting-started/installation-update.md" %}
[installation-update.md](getting-started/installation-update.md)
{% endcontent-ref %}

## Feature walk-through

#### 1. Create UI components in pure Ruby

Craft your UI based on your components written in pure Ruby. Utilizing Ruby's amazing language features, you're able to create a cleaner and more maintainable UI implementation.

**Implement UI components in pure Ruby**

Create Ruby classes within your Rails project and call Matestack's core components through a Ruby DSL in order to craft your UIs. The Ruby method "div" for example calls one of the static core components, responsible for rendering HTML tags. A component can take Strings, Integers Symbols, Arrays or Hashes (...) as optional properties (e.g. "title") or require them (e.g. "body").

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

**Use your Ruby UI components on your existing Rails views**

Components can be then called on Rails views (not only! see below), enabling you to create a reusable card components, abstracting UI complexity in your own components.

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= Components::Card.call(title: "hello", body: "world") %>
<!-- some other erb markup -->
```

**Use Ruby methods as partials**

Split your UI implementation into multiple small chunks helping others (and yourself) to better understand your implementation. Using this approach helps you to create a clean, readable and maintainable codebase.

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
      plain footer
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

**Use class inheritance**

Because it's just a Ruby class, you can use class inheritance in order to further improve the quality of your UI implementation. Class inheritance can be used to easily create variants of UI components but still reuse parts of the implementation.

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

**Use components within components**

Just like you used matestack's core components on your own UI component, you can use your own UI components within other custom UI components. You decide when using a Ruby method partial should be replaced by another self contained UI component!

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

**Yield components into components**

Sometimes it's not enough to just pass simple data into a component. No worries! You can just yield a block into your components! Using this approach gives you more flexibility when using your UI components. Ofcourse yielding can be used alongside passing in simple params.

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

**Use named slots for advanced content injection**

If you need to inject multiple blocks into your UI component, you can use "slots"! Slots help you to build complex UI components with multiple named content placeholders for highest implementation flexibility!

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

#### 2. Substitute Rails Views with Matestack Pages

Until here we used Matestack components on Rails views. If desired you can go one step further and use Matestack components on something called a Matestack Page:

A Matestack page can be compared to a Rails view and might be yielded within a layout provided by an associated Matestack layout class (see below). The page itself uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/pages/some_page.rb" %}
```ruby
class Pages::SomePage < Matestack::Ui::Page

  def response
    div class: "container" do
      span id: "hello" do
        plain "hello world!"
      end
      Components::Card.call(title: "foo", body: "bar")
    end
  end

end
```
{% endcode %}

Pages are used as Rails view substitutes and therefore called in a Rails controller action:

{% code title="app/controllers/some_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::SomePage
  end

end
```
{% endcode %}

The page response - in this case - will be yielded into the Rails layout if not specified differently.

#### 3. Wrap Matestack Pages in Matestack Layouts

Just like a Rails layout would yield a Rails view, a Matestack layout yields a Matestack page. The layout uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/some_app/some_layout.rb" %}
```ruby
class SomeApp::SomeLayout < Matestack::Ui::Layout

  def response
    h1 "Some App"
    main do
      yield
    end
  end

end
```
{% endcode %}

In this basic example the layout is using the methods `h1` and `main` in order to create the markup as well as a `yield` in order to yield a page on a specific position.

{% hint style="info" %}
A Matestack layout itself will be yielded into the Rails layout, unless the Rails layout is disabled in the controller via:`layout false`
{% endhint %}

Usually a layout implies a specific context of your application. Multiple pages are then scoped within that context, which could lead to a file structure like:

```bash
app/matestack/
|
└───some_app/
│   │   some_layout.rb
│   └───pages/
│   │   │   page1.rb
│   │   │   page2.rb
│   │   │   page3.rb
```

and then used in a controller like this:



### Feature walk-through

#### 1. Create UI components in pure Ruby

Craft your UI based on your components written in pure Ruby. Utilizing Ruby's amazing language features, you're able to create a cleaner and more maintainable UI implementation.

**Implement UI components in pure Ruby**

Create Ruby classes within your Rails project and call Matestack's core components through a Ruby DSL in order to craft your UIs. The Ruby method "div" for example calls one of the static core components, responsible for rendering HTML tags. A component can take Strings, Integers Symbols, Arrays or Hashes (...) as optional properties (e.g. "title") or require them (e.g. "body").

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

**Use your Ruby UI components on your existing Rails views**

Components can be then called on Rails views (not only! see below), enabling you to create a reusable card components, abstracting UI complexity in your own components.

`app/views/your_view.html.erb`

```erb
<!-- some other erb markup -->
<%= Components::Card.call(title: "hello", body: "world") %>
<!-- some other erb markup -->
```

**Use Ruby methods as partials**

Split your UI implementation into multiple small chunks helping others (and yourself) to better understand your implementation. Using this approach helps you to create a clean, readable and maintainable codebase.

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
      plain footer
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

**Use class inheritance**

Because it's just a Ruby class, you can use class inheritance in order to further improve the quality of your UI implementation. Class inheritance can be used to easily create variants of UI components but still reuse parts of the implementation.

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

**Use components within components**

Just like you used matestack's core components on your own UI component, you can use your own UI components within other custom UI components. You decide when using a Ruby method partial should be replaced by another self contained UI component!

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

**Yield components into components**

Sometimes it's not enough to just pass simple data into a component. No worries! You can just yield a block into your components! Using this approach gives you more flexibility when using your UI components. Ofcourse yielding can be used alongside passing in simple params.

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

**Use named slots for advanced content injection**

If you need to inject multiple blocks into your UI component, you can use "slots"! Slots help you to build complex UI components with multiple named content placeholders for highest implementation flexibility!

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

#### 2. Substitute Rails Views with Matestack Pages

Until here we used Matestack components on Rails views. If desired you can go one step further and use Matestack components on something called a Matestack Page:

A Matestack page can be compared to a Rails view and might be yielded within a layout provided by an associated Matestack layout class (see below). The page itself uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/pages/some_page.rb" %}
```ruby
class Pages::SomePage < Matestack::Ui::Page

  def response
    div class: "container" do
      span id: "hello" do
        plain "hello world!"
      end
      Components::Card.call(title: "foo", body: "bar")
    end
  end

end
```
{% endcode %}

Pages are used as Rails view substitutes and therefore called in a Rails controller action:

{% code title="app/controllers/some_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  def overview
    render Pages::SomePage
  end

end
```
{% endcode %}

The page response - in this case - will be yielded into the Rails layout if not specified differently.

#### 3. Wrap Matestack Pages in Matestack Layouts

Just like a Rails layout would yield a Rails view, a Matestack layout yields a Matestack page. The layout uses Matestack's HTML rendering mechanism in a `response` method and may additionally call other components in order to define a specific UI.

{% code title="app/matestack/some_app/some_layout.rb" %}
```ruby
class SomeApp::SomeLayout < Matestack::Ui::Layout

  def response
    h1 "Some App"
    main do
      yield
    end
  end

end
```
{% endcode %}

In this basic example the layout is using the methods `h1` and `main` in order to create the markup as well as a `yield` in order to yield a page on a specific position.

{% hint style="info" %}
A Matestack layout itself will be yielded into the Rails layout, unless the Rails layout is disabled in the controller via:`layout false`
{% endhint %}

Usually a layout implies a specific context of your application. Multiple pages are then scoped within that context, which could lead to a file structure like:

```bash
app/matestack/
|
└───some_app/
│   │   some_layout.rb
│   └───pages/
│   │   │   page1.rb
│   │   │   page2.rb
│   │   │   page3.rb
```

and then used in a controller like this:

{% code title="app/controllers/some_controller.rb" %}
```ruby
class SomeController < ApplicationController

  include Matestack::Ui::Core::Helper

  matestack_layout SomeApp::SomeLayout

  def page_1
    render SomeApp::Pages::Page1
  end

  def page_2
    render SomeApp::Pages::Page2
  end

  def page_3
    render SomeApp::Pages::Page3, matestack_layout: false # skip app layout on this page
  end

end
```
{% endcode %}
