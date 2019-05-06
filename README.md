[![CircleCI](https://circleci.com/gh/basemate/matestack-ui-core/tree/master.svg?style=shield)](https://circleci.com/gh/basemate/matestack-ui-core/tree/master)
[![Gitter](https://badges.gitter.im/basemate/community.svg)](https://gitter.im/basemate/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Gem Version](https://badge.fury.io/rb/matestack-ui-core.svg)](https://badge.fury.io/rb/matestack-ui-core)

![matestack logo](./logo.png)

# matestack: Escape the frontend hustle

## Create maintainable, dynamic and beautiful UIs easily

As a Rails Engine, matestack deeply integrates a Vue.js based UI into Rails, offering optional prebuilt components. Use it to write dynamic Web-UIs with minimum effort and maximum dev happiness in pure Ruby. The main goals are:

- Reduction of complexity of modern web development, moving front and backend closer together
- More maintainable UI code, using a component-based structure written in Ruby
- Increased development speed and happiness, offering prebuilt UI-Components for classic requirements
- Modern, dynamic UI feeling without the need to implement a separate JavaScript Application

matestack can progressively replace the classic Rails-View-Layer. You are able to use
it alongside your classic views and incrementally turn your Rails-App into a
dynamic Web-App.

### Features:

#### Define your UI in a Ruby Class
```ruby
class Pages::MyPage < Page::Cell::Page

  def prepare
    @technologies = ["Rails", "Vue.js", "Trailblazer", "Rspec", "Capybara"]
  end

  def response
    components{
      div id: "technologies" do
        @technologies.each do |technology|
          plain "matestack uses #{technology}"
        end
      end
    }
  end

end
```
#### Create a Single Page Application without JavaScript

```ruby
class Apps::MyApp < App::Cell::App

  def response
    components{
      header do
        heading size: 1, text: "My App"
      end
      nav do
        transition path: :my_first_page_path do
          button "Page 1"
        end
        transition path: :my_second_page_path do
          button "Page 2"
        end
      end
      main do
        page_content #pages are dynamically yielded here, when buttons are clicked!
      end
      footer do
        plain "That's it!"
      end
    }
  end

end
```

```ruby
class Pages::MyApp::MyFirstPage < Page::Cell::Page

  def response
    components{
      div id: "div-on-page-1" do
        plain "My First Page"
      end
    }
  end

end
```
```ruby
class Pages::MyApp::MySecondPage < Page::Cell::Page

  def response
    components{
      div id: "div-on-page-2" do
        plain "My Second Page"
      end
    }
  end

end
```
#### Handle User Interaction dynamically without JavaScript
```ruby
class Pages::MyPage < Page::Cell::Page

  def response
    components {
      action my_action_config do
        button text: "Click me!"
      end
      #content gets rerendered without page reload if action succeeded
      async rerender_on: "my_action_succeeded" do
        div id: "my-div" do
          plain DateTime.now
        end
      end
    }
  end

  def my_action_config
    {
      method: :post,
      path: :some_rails_routing_path,
      success: {
        emit: "my_action_succeeded"
      }
    }
  end

end
```
#### Handle User Input dynamically without JavaScript
```ruby
class Pages::MyApp::MyFirstPage < Page::Cell::Page

  def prepare
    @my_model = MyModel.new
  end

  def response
    components {
      form my_form_config, :include do
        form_input key: :some_model_attribute, type: :text
        form_submit do
          button text: "Submit me!"
        end
      end
      async show_on: "form_has_errors", hide_after: 5000 do
        plain "Data could not be submitted, please check form"
      end
    }
  end

  def my_form_config
    {
      for: @my_model,
      method: :post,
      path: :some_action_path,
      success: {
        transition: {
          path: :my_second_page_path,
        }
      },
      failure: {
        emit: "form_has_errors"
      }
    }
  end

end
```
#### Websocket Integration without JavaScript
```ruby
class Pages::MyPage < Page::Cell::Page

  def prepare
    @comments = Comment.last(5)
  end

  def response
    components {
      #content gets rerendered without page reload when
      #websocket event is received
      async rerender_on: "comments_changed" do
        @comments.each do |comment|
          div do
            plain comment.content
          end
        end
      end
    }
  end

end
```
somewhere else on the backend:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  message: "comments_changed"
})
```

### Documentation

Documentation can be found [here](./docs)

### Changelog

Changelog can be found [here](./CHANGELOG.md)

### Roadmap

Scheduled for 0.7.0:
- Better naming conventions
- Webpacker/Yarn Integration
- Advanced Websockets Integration
- 1:n Relations in Form components
- More Form Components (Multi Select Components)
- Component Based Caching
- Rails View Integration
- Dockerized Core Development


### Community

As a low-barrier feedback channel for our early users, we have set up a Gitter chat that can be found [here](https://gitter.im/basemate/community). You are very welcome to ask questions and send us feedback there!

### Contribution

We are happy to accept contributors of any kind. Please refer to the [Contribution Guide](./docs/contribute)

### License
The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
