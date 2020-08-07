# Matestack Core Component: Async

Feel free to check out the [component specs](/spec/usage/components/async_spec.rb).

As the name suggests, the async component allows us to let our components behave asynchronously!

Please be aware that, if not configured otherwise, the async core component does get loaded and displayed on initial pageload!

## Parameters

The async core component accepts the following parameters:

### Rerender_on

The `rerender_on` option lets us define an event on which the component gets rerendered.

```ruby
async rerender_on: 'my_event' do
  div id: 'my-div' do
    plain "#{DateTime.now.strftime('%Q')}"
  end
end
```

**Note:** The `rerender_on` option lets you rerender parts of your UI asynchronously, which is cool. But please consider that, if not configured differently, it a) is **not** _lazily loaded_ and b) does get displayed on initial pageload.

Lazy (or defered) loading can be configured like shown  [here](#defer).

If you want to simply hide the async component on initial pageload and display it later on, read below how to use `show_on`, which can be combined with `rerender_on`.

You can pass in multiple, comma-separated events on which the component should rerender.

```ruby
async rerender_on: 'my_event, some_other_event'
```

### Show_on

The `show_on` option lets us define an event on which the component gets shown. The content is still rendered on init pageload, but simply hidden in the browser until the event is emitted. If you want to have proper deferred loading, please refer to [defer](#defer)

```ruby
async show_on: 'my_event' do
  div id: 'my-div' do
    plain 'I was not here before the event'
  end
end
```

You can pass in multiple, comma-separated events on which the component should be shown.

```ruby
async show_on: 'my_event, some_other_event'
```

### Hide_on

The `hide_on` option lets us define an event on which the component gets hidden.

```ruby
async hide_on: 'my_event' do
  div id: 'my-div' do
    plain 'You will not see me after the event'
  end
end
```

You can pass in multiple, comma-separated events on which the component should be hidden.

```ruby
async hide_on: 'my_event, some_other_event'
```


### Hide_after

The `hide_after` option lets us define a timespan in milliseconds after which the component gets hidden.

```ruby
async hide_after: 1000 do
  div id: 'my-div' do
    plain 'I will be hidden after 1000ms'
  end
end
```

### Shown_on/Hide_on Combination

If you combine `shown_on` and `hide_on`, you can toggel the view state of the `async` component explicitly.

By default, the content is initially hidden until the show event is emitted when `shown_on` is applied.

```ruby
async shown_on: "my_show_event", hide_on: 'my_hide_event' do
  div id: 'my-div' do
    plain 'You will not see me after the event'
  end
end
```

 If you want to display the content initially, simply add `init_show: true`

```ruby
async shown_on: "my_show_event", hide_on: 'my_hide_event', init_show: true do
  div id: 'my-div' do
    plain 'You will not see me after the event'
  end
end
```

### Defer

The `defer` option may be used in two ways:

#### simple defer
`defer: true` implies that the content of the `async` component gets requested within a separate GET request right after initial page load is done.
```ruby
async defer: true do
  div id: 'my-div' do
    plain 'I will be requested within a separate GET request right after initial page load is done'
  end
end
```

#### delayed defer
`defer: 2000` means that the content of the `async` component gets requested within a separate GET request 2000 milliseconds after initial page load is done.
```ruby
async defer: 2000 do
  div id: 'my-div' do
    plain 'I will be requested within a separate GET request 2000ms after initial page load is done'
  end
end
```

The content of an `async` component with activated `defer` behavior is not resolved within the first page load!

```ruby
#...
async defer: 1000 do
  some_database_data = SomeModel.some_heavy_query
  div id: 'my-div' do
    some_database_data.each do |some_instance|
      plain some_instance.id
    end
  end
end
async defer: 2000 do
  some_other_database_data = SomeModel.some_other_heavy_query
  div id: 'my-div' do
    some_other_database_data.each do |some_instance|
      plain some_instance.id
    end
  end
end
#...
```

The `SomeModel.some_query` does not get executed within the first page load and only will be called within the deferred GET request. This helps us to render a complex UI with loads of heavy method calls step by step without slowing down the initial page load and rendering of simple content.

#### defer used with show_on and hide_on
You can trigger the deferred GET request base on a client-side event fired by an `onclick` component for example.

```ruby
onclick emit: "my_event" do
  button text: "show"
end
onclick emit: "my_other_event" do
  button text: "hide"
end
async defer: true, show_on: "my_event", hide_on: "my_other_event" do
  div id: 'my-div' do
    plain 'I will be requested within a separate GET request right after "my_event" is fired'
  end
end
```
Everytime the `async` section gets shown, the content of the `async` component gets freshly fetched from the server!

## Examples

See some common use cases below:

### Example 1 - Rerender on event

On our example page, we wrap a simple timestamp in an async component and tell it to rerender when the event `my_event` gets triggered.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async rerender_on: 'my_event' do
        div id: 'my-div' do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

end
```

Not surprisingly, the timestamp gets updated after our event was fired!

### Example 2: Show on event

On our example page, we wrap a simple timestamp in an async component and tell it to show up when the event `my_event` gets triggered.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async show_on: 'my_event' do
        div id: 'my-div' do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

end
```

_After_ our event was fired, the timestamp only is visible on our page!

### Example 3: Hide on event

On our example page, we wrap a simple timestamp in an async component and tell it to hide it when the event `my_event` gets triggered.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async hide_on: 'my_event' do
        div id: 'my-div' do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

end
```

As expected, the timestamp is only visible _before_ our event was fired and is hidden/invisible _after_ the event!

### Example 3.1: Rerender/Show/Hide Combination for inline editing

Imagine, you want to create an inline edit form. Using a combination of `show_on`, `hide_on`, `init_show:true` and `rerender_on` allows you to implement this easily like shown below:


```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @my_model = MyModel.find(42)
  end

  def response
    components {
      partial :show_value
      partial :show_form
    }
  end

  def show_value
    partial {
      async rerender_on: "item_updated", show_on: "item_updated", hide_on: "update_item", init_show: true do
        onclick emit: "update_item" do
          plain @my_model.title
        end
      end
    }
  end

  def show_form
    partial {
      async rerender_on: "item_updated", show_on: "update_item", hide_on: "item_updated" do
        form some_form_config, :include do
          form_input key: :title, type: :text
          form_submit do
            button text: "save"
          end
        end
        onclick emit: "item_updated" do
          button text: "abort"
        end
      end
    }
  end

  def some_form_config
    {
      for: @my_model,
      method: :post,
      path: :inline_form_action_path, #or any other rails route
      params: {
        id: @my_model.id
      },
      success:{
        emit: "item_updated"
      }
    }
  end

end
```
 If you click on the attribute value, the form gets shown. After successful form submission, the form gets hidden again and only the simple value is shown.

### Example 4: Hide after show on event

On our example page, we wrap a simple timestamp in an async component and tell it to show up when the event `my_event` gets triggered and be hidden after 1000 milliseconds.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async show_on: 'my_event', hide_after: 1000 do
        div id: 'my-div' do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

end
```

In this case, the timestamp only is visible _after_ our event was fired, but only for a certain amount of time. After the time is up, it gets hidden!

### Example 5: Show on event with event payload

On our example page, we wrap our async event around a placeholder for the event message.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async show_on: 'my_event' do
        div id: 'my-div' do
          plain "{{event.data.message}}"
        end
      end
    }
  end

end
```

As an example, we can fire the following event:

```ruby
page.execute_script('MatestackUiCore.matestackEventHub.$emit("my_event", { message: "test!" })')
```

As a result, the event message gets shown _after_ our event was fired!

### Example 6: Deferred loading

On our example page, we wrap our async event around a placeholder for the event message.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      async defer: true do
        div id: 'my-div' do
          plain 'I will be requested within a separate GET request right after initial page load is done'
        end
      end
    }
  end

end
