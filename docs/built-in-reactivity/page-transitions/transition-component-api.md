# Transition Component API

Performing dynamic page transitions without full page reload.

## Parameters

Except for `id` and `class`, the transition component can handle additional parameters:

### path - required

As the name suggests, the `path` expects a path within our application. If you want to route to a link outside our application, use the `a` method, rendering a typical HTML `a` tag

```ruby
transition path: page1_path do
  button 'Page 1'
end
```

If the path input is a **string** it just uses this string for the transition target.

You can also just use the Rails url helper methods directly. They will return a string which is then used as the transition target without any further processing.

### text

If the transition component receives a text via the first argument, it gets rendered as shown here:

```ruby
transition 'Click me for a transition', path: page1_path
```

```markup
<a href='my_example_app/page1'>Click me for a transition</a>
```

If no text is present, the transition component expects a block that it then _yields_ the usual way.

### delay

You can use this attribute if you want to delay the actual transition. It will not delay the `page_loading_triggered` event

```ruby
delay: 1000 # means 1000 ms
```

## Active class

The `transition` component automatically gets the `active` class on the clientside when the current path equals the target path.

When a sub page of a parent `transition` component is currently active, the parent `transition` component gets the `active-child` class. A sub page is recognized if the current path is included in the target path of the parent `transition` component:

Parent target: `/some_page`

Currently active: `/some_page/child_page` --&gt; Parent gets `child-active`

Query params do not interfere with this behavior.

## Events

The `transition` component automatically emits events on:

* transition triggered by user action -&gt; "page\_loading\_triggered"
* _optional client side delay via `delay` attribute_
* start to get new page from server -&gt; "page\_loading"
* _server side/network delay_
* successfully received new page from server -&gt; "page\_loaded"
* failed to receive new page from server -&gt; "page\_loading\_error"

## Examples

The transition core component renders the HTML `<a>` tag and performs a page transition

### Perform transition from one page to another without full page reload

First, we define our routes \(`config/routes.rb`\) and the corresponding endpoints in our example controller:

```ruby
get 'my_example_app/page1', to: 'example_app_pages#page1', as: 'page1'
get 'my_example_app/page2', to: 'example_app_pages#page2', as: 'page2'
```

```ruby
class ExampleAppPagesController < ExampleController

  include Matestack::Ui::Core::Helper
  
  matestack_app ExampleApp

  def page1
    render ExampleApp::Pages::ExamplePage
  end

  def page2
    render ExampleApp::Pages::SecondExamplePage
  end

end
```

Then, we define our example app layout with a navigation that consists of two transition components!

```ruby
class ExampleApp::Apps < Matestack::Ui::App

  def response
    h1 'My Example App Layout'
    nav do
      transition path: page1_path do
        button 'Page 1'
      end
      transition path: page2_path do
        button 'Page 2'
      end
    end
    main do
      yield
    end
  end

end
```

Lastly, we define two example pages for our example application:

```ruby
class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page

  def response
    div id: 'my-div-on-page-1' do
      h2 'This is Page 1'
      plain "#{DateTime.now.strftime('%Q')}"
    end
  end

end
```

and

```ruby
class ExampleApp::Pages::SecondExamplePage < Matestack::Ui::Page

  def response
    div id: 'my-div-on-page-2' do
      h2 'This is Page 2'
      plain "#{DateTime.now.strftime('%Q')}"
    end
    transition path: page1_path do
      button 'Back to Page 1'
    end
  end

end
```

Now, we can visit our first example page via `localhost:3000/my_example_app/page1` and see our two buttons \(`Page 1` and `Page 2`\) and the content of page 1 \(`My Example App Layout` and `This is Page 1`\).

After clicking on the `Page 2`-button, we get transferred to our second page \(`This is Page 2`\) without re-loading the whole page.

If we then click the other button available \(`Back to Page 1`\), we get transferred back to the first page, again without re-loading the whole page. This behavior can save quite some request payload \(and therefore loading time\) as only the relevant content on a page gets replaced!

