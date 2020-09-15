# Matestack Core Component: Onclick

The `onclick` component renders a div that runs a function when the user clicks on it. This is a simple component that can be used to wrap components with a onclick function that will emit an event. The event that must be emitted onclick can defined by passing a hash into the `onclick` component that has the key `emit`. See example below for more details.

## Parameters

### emit - required

Takes a string or symbol. An event with this name will be emitted using the matestack event hub.

**You currently cannot pass in an event payload.**

## Examples

### Example 1 - Emitting an event which triggers an asynchronous rerendering via `async`

```ruby
class ExamplePage < Matestack::Ui::Page
  def response
    onclick emit: "abc" do
      button text: "rerender something"
    end
    async rerender_on: "abc", id: "some-unique-id" do
      plain "Render this text when the 'abc' event is emitted"
    end
  end
end
```
