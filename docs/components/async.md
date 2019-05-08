# matestack core component: Async

Show [specs](../../spec/usage/components/async_spec.rb)

The async component allows us to ...!

## Parameters

The core async component accepts the following parameters:

### Rerender_on

Lalala

```ruby
method: :post
```

### Show_on

Lalala

```ruby
method: :post
```

### Hide_on

Lalala

```ruby
method: :post
```

### Hide_after

Lalala

```ruby
method: :post
```

## Examples

See two common use cases below:

### Example 1 - Rerender on event

On our example page, we wrap a simple timestamp in an async component and tell it to rerender when the event `my_event` gets triggered.

```ruby
class ExamplePage < Page::Cell::Page

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
class ExamplePage < Page::Cell::Page

  def response
    components {
      async show_on: "my_event" do
        div id: "my-div" do
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
class ExamplePage < Page::Cell::Page

  def response
    components {
      async hide_on: "my_event" do
        div id: "my-div" do
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

end
```

As expected, the timestamp only is hidden _after_ our event was fired!

### Example 4: Hide after show on event

On our example page, we wrap a simple timestamp in an async component and tell it to show up when the event `my_event` gets triggered and be hidden after 1000ms.

```ruby
class ExamplePage < Page::Cell::Page

  def response
    components {
      async show_on: "my_event", hide_after: 1000 do
        div id: "my-div" do
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
class ExamplePage < Page::Cell::Page

  def response
    components {
      async show_on: "my_event" do
        div id: "my-div" do
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
