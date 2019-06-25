# App Concept

Show [specs](../../spec/usage/base/app_spec.rb)

## An App can wrap pages with a layout

`app/matestack/apps/example_app.rb`

```ruby
class Apps::ExampleApp < Matestack::Ui::App

  def response
    components {
      heading size: 1, text: "My Example App Layout"
      main do
        #page_content is a core component enabling dynamic transitions
        #it can be placed anywhere in your layout
        page_content
      end
    }
  end

end
```

`app/matestack/pages/example_app/example_page.rb`

```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "my-div-on-page-1" do
        heading size: 2, text: "This is Page 1"
      end
    }
  end

end
```

`app/matestack/pages/example_app/second_example_page.rb`

```ruby
class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

  def response
    components {
      div id: "my-div-on-page-2" do
        heading size: 2, text: "This is Page 2"
      end
    }
  end

end
```

## An App enables transitions between pages without page reload

`app/matestack/apps/example_app.rb`

```ruby
class Apps::ExampleApp < Matestack::Ui::App

  def response
    components {
      heading size: 1, text: "My Example App Layout"
      nav do
        transition path: :app_specs_page1_path do
          button text: "Page 1"
        end
        transition path: :app_specs_page2_path do
          button text: "Page 2"
        end
      end
      main do
        page_content
      end
    }
  end

end
```

For more informations on transitions, visit [transitions](../components/transition.md)
