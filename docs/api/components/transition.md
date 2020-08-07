# Matestack Core Component: Transition

Feel free to check out the [component specs](/spec/usage/components/transition_spec.rb).

## Parameters

Except for `id` and `class`, the transition component can handle additional parameters:

### Path

As the name suggests, the `options[:path]` expects a path within our application. If you want to rout to a link outside our application, use the [link component](/docs/components/link.md)

```ruby
transition path: :page1_path do
  button text: 'Page 1'
end
```

### Text

If the transition component receives a text via its `options`, it gets rendered as shown here:

```ruby
transition path: :page1_path, text: 'Click me for a transition'
```

```HTML
<a href='my_example_app/page1'>Click me for a transition</a>
```

If no text is present, the transition component expects a block that it then *yields* the usual way.

### Active class

The `transition` component automatically gets the `active` class on the clientside when the current path equals the target path.

When a sub page of a parent `transition` component is currently active, the parent `transition` component gets the `active-child` class. A sub page is recognized if the current path is included in the target path of the parent `transition` component:

Parent target: `/some_page`

Currently active: `/some_page/child_page` --> Parent gets `child-active`

Query params do not interfere with this behavior.

### Delay

You can use this attribute if you want to delay the actual transition. It will not delay the `page_loading_triggered` event

```ruby
delay: 1000 # means 1000 ms
```

### Events

The `transition` component automatically emits events on:

* transition triggered by user action -> "page_loading_triggered"
* *optional client side delay via `delay` attribute*
* start to get new page from server -> "page_loading"
* *server side/network delay*
* successfully received new page from server -> "page_loaded"
* failed to receive new page from server -> "page_loading_error"

## Examples

The transition core component renders the HTML `<a>` tag and performs a page transition

### Example 1: Perform transition from one page to another without full page reload

First, we define our routes (`config/routes.rb`) and the corresponding endpoints in our example controller:

```ruby
get 'my_example_app/page1', to: 'example_app_pages#page1', as: 'page1'
get 'my_example_app/page2', to: 'example_app_pages#page2', as: 'page2'
```

```ruby
class ExampleAppPagesController < ExampleController
  include Matestack::Ui::Core::ApplicationHelper

  def page1
    responder_for(Pages::ExampleApp::ExamplePage)
  end

  def page2
    responder_for(Pages::ExampleApp::SecondExamplePage)
  end

end
```

Then, we define our example app layout with a navigation that consists of two transition components!

```ruby
class Apps::ExampleApp < Matestack::Ui::App

  def response
    components {
      heading size: 1, text: 'My Example App Layout'
      nav do
        transition path: :page1_path do
          button text: 'Page 1'
        end
        transition path: :page2_path do
          button text: 'Page 2'
        end
      end
      main do
        page_content
      end
    }
  end

end
```

Lastly, we define two example pages for our example application:

```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: 'my-div-on-page-1' do
        heading size: 2, text: 'This is Page 1'
        plain "#{DateTime.now.strftime('%Q')}"
      end
    }
  end

end
```

and

```ruby
class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: 'my-div-on-page-2' do
        heading size: 2, text: 'This is Page 2'
        plain "#{DateTime.now.strftime('%Q')}"
      end
      transition path: :page1_path do
        button text: 'Back to Page 1'
      end
    }
  end

end
```

Now, we can visit our first example page via `localhost:3000/my_example_app/page1` and see our two buttons (`Page 1` and `Page 2`) and the content of page 1 (`My Example App Layout` and `This is Page 1`).

After clicking on the `Page 2`-button, we get transferred to our second page (`This is Page 2`) without re-loading the whole page.

If we then click the other button available (`Back to Page 1`), we get transferred back to the first page, again without re-loading the whole page. This behavior can save quite some request payload (and therefore loading time) as only the relevant content on a page gets replaced!
