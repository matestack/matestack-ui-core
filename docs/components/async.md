# matestack core component: Async

Show [specs](../../spec/usage/components/async_spec.rb)

As the name suggests, the async component allows us to let our components behave asynchronously!

Please be aware that, if not configured otherwise, the async core component does get loaded and displayed on initial pageload!

**the async component currently only works on page-level --> we're working on it in order support the usage of async within a component [#75](https://github.com/basemate/matestack-ui-core/issues/75)**

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

Lazy (or defered) loading is a feature we're working on right now, for details see [here](https://github.com/basemate/matestack-ui-core/issues/58).

If you want to hide the async component on initial pageload and display it later on, read below as this option (`show_on`) is already implemented (and can be combined with `rerender_on`)!

### Show_on

The `show_on` option lets us define an event on which the component gets shown.

```ruby
async show_on: 'my_event' do
  div id: 'my-div' do
    plain 'I was not here before the event'
  end
end
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

### Hide_after

The `hide_after` option lets us define a timespan after which the component gets hidden.

```ruby
async hide_after: 1000 do
  div id: 'my-div' do
    plain 'I will be hidden after 1000ms'
  end
end
```

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

### Example 4: Hide after show on event

On our example page, we wrap a simple timestamp in an async component and tell it to show up when the event `my_event` gets triggered and be hidden after 1000ms.

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
