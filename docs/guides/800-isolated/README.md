# Isolated

Matestacks concept of isolated components has a lot in common with `async` components. Isolated components can be deferred or asynchronously rerendered like `async` components. In the difference to `async` components, isolated components are resolved completetly independent from the rest of the ui. If an isolated component gets rerendered or loaded matestack will directly render this component without touching the app or page. With `async` matestack searches in an app or page which component needs to be rerendered. Therefore executing parts of an app and page whereas isolated components don't.

Isolated components can not be called or used with a block like `async`, instead you need to create a component inheriting from `Matestack::Ui::IsolatedComponent`. Creation of the custom component works similar to other components, except you need to implement an `authorized?` method. As said above isolated components are completly independent and could be called directly via a url, therefore they need custom authorization. More about that later. 

Isolated components are perfectly when you have long runnning, complex database queries or business logic which concludes to slow page loads. Use an isolated component with the `:defer` option to keep your page loads fast and present the result to the user asynchronously.

## Usage

To create an isolated component you need to create a component which inherits from `Matestack::Ui::IsolatedComponent`. Implementing your component is straight forward. As always you implement a `response` method which defines what get's rendered. 

```ruby
class CurrentTime < IsolatedComponent

  def response
    div class: 'time' do
      paragraph text: Time.now
    end
  end

  def authorized?
    true
  end

end
```

Register it like a usual component.

```ruby
module ComponentsRegistry
  Matestack::Ui::Core::Component::Registry.register_components(
    current_time: CurrentTime
  )
```

And use it with the `:defer` or `:rerender_on` options which work the same on `async` components.

```ruby
def response
  current_time defer: 1000, rerender_on: 'update-time'
end
```

### Deferred loading

You can configure your isolated component to request its content directly after the page load or to delay the request for a given amount of time after the page load instead of being rendered with the page. `:defer` expects either a boolean or a integer representing the delay time in milliseconds. If `:defer` is set to `false` your isolated component will be rendered on page load and not deferred. If set to `true` it will request its content directly after the page load.

```ruby
def response
  current_time defer: true
end
```

The above call to your isolated component will be skipped on page load and the component will request its content asynchronously directly after the page is loaded.

```ruby
def response
  current_time defer: 500
end
```

This will load your isolated component 500ms after the page is loaded.

### Rerendering content

Isolated component leverage the event hub and can react to emitted events. If they receive one or more of the with `:rerender_on` specified events they will asynchronously request a rerender of their content. The server will only render the isolated component, not touching any of the apps or pages. The response will only include the rerendered html of the isolated component which then swaps out its current content with the response. If you specify multiple events in `:rerender_on` they need to be seperated by a comma.

```ruby
def response
  current_time rerender_on: 'update-time'
  onclick emit: 'update-time' do
    button text: 'Update time'
  end
end
```

The above snippet renders our `current_time` isolated component and a button "Update time" on page load. If the button is clicked a _update-time_ event is emitted. Our isolated component receives the event and reacts to it by requesting its rerendered content from the server and replacing its content with the received html. In this case it will rerender after button click and show the updated time.

Remember that you can use ActionCable to emit events on the serverside.

### Authorization

When asynchronously rendering isolated components, these HTTP calls are actually
processed by the controller action responsible for the corresponding page rendering.
One might think, that the optional authorization and authentication rules of that
controller action should therefore be enough for securing isolated components rendering.

But that's not true. It would be possible to hijack public controller actions without
any authorization in place and request isolated components which are only meant to be
rendered within a secured context.

That's why we enforce the usage of the `authorized?` method to make sure, all isolated
components take care of their authorization themselves.

If `authorized?` returns `true`, the component will be rendered. If it returns `false`,
the component will not be rendered.

A public isolated component therefore needs an `authorized?` method simply returning `true`.

This might sound complicated, but it is not. For example using devise you can access the controller helper `current_user` inside your isolated component, making authorization implementations as easy as:

```ruby
def authorized?
  current_user.present?
end
```

### Data acquisition

Use the `prepare` method in order to gather needed information from long running queries or complex business logic or use methods. The `prepare` method is executed before the `response`. 

```ruby
class BookingsList < IsolatedComponent

  def prepare
    @bookings = Booking.some_long_running_query
  end

  def response
    @bookings.each do |booking|
      paragraph text: booking.details
    end
    availabilities.each do |availability|
      paragraph text: availability.details
    end
  end

  def authorized?
    true
  end

  def availabilities
    Booking.some_long_runnning_availability_check
  end

end
```

Deferring such slow parts of your ui speeds up your page load significantly. But remember to always try to improve your query or logic performance as isolated components are not your general solution to fast page loads.


### Loading animations

Isolated components are wrapped in a special html structure allowing you to create animations while the components gets loaded or rerendered. It appends a loading class to the wrapping elements while the component is loading or rerendering. To learn more about how to animate loading isolated components checkout its [api documentation](/docs/api/100-components/async.md).


## Complete documentation

If you want to know all details about isolated components checkout its [api documentation](/docs/api/000-base/40-isolated_component.md).