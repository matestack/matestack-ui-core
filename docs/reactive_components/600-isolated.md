# Isolated

Matestacks concept of isolated components has a lot in common with `async` components. Isolated components can be deferred or asynchronously rerendered like `async` components. In the difference to `async` components, isolated components are resolved completetly independent from the rest of the ui. If an isolated component gets rerendered or loaded matestack will directly render this component without touching the app or page. With `async` matestack searches in an app or page which component needs to be rerendered. Therefore executing parts of an app and page whereas isolated components don't.

Isolated components can not be called or used with a block like `async`, instead you need to create a component inheriting from `Matestack::Ui::IsolatedComponent`. Creation of the custom component works similar to other components, except you need to implement an `authorized?` method. As said above isolated components are completly independent and could be called directly via a url, therefore they need custom authorization. More about that later.

Isolated components are perfectly when you have long runnning, complex database queries or business logic which concludes to slow page loads. Use an isolated component with the `:defer` option to keep your page loads fast and present the result to the user asynchronously.

## Differences to simple components

Your isolated components can by design not

* yield components passed in by using a block
* yield slots passed in by using slots
* simply get options injected by surrounding context

They are meant to be `isolated` and resolve all data independently! That's why they can be rendered completely separate from the rest of the UI.

Furthermore isolated components have to be authorized independently. See below.

## Differences to the `async` component

The [`async` component](https://github.com/matestack/matestack-ui-core/tree/0e84336eae78e6c86403c0c60fbe8fca4bcd8081/docs/reactive_components/600-isolated/docs/api/100-components/core/async.md) offers pretty similar functionalities enabling you to define asynchronous rendering. The important difference is that rerendering an `async` component requires resolving the whole page on the serverside, which can be performance critical on complex pages. An isolated component bypasses the page and can therefore offer high performance rerendering.

Using the `async` component does NOT require you to create a custom component:

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    async id: "some-unique-id", rerender_on: "some-event" do
      div id: 'my-async-wrapper' do
        plain I18n.l(DateTime.now)
      end
    end
  end
end
```

Using an isolated component does require you to create a custom component:

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated rerender_on: "some-event"
  end
end
```

Isolated components should be used on complex UIs where `async` rerendering would be performance critical or you simply wish to create cleaner and more decoupled code.

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

When asynchronously rendering isolated components, these HTTP calls are actually processed by the controller action responsible for the corresponding page rendering. One might think, that the optional authorization and authentication rules of that controller action should therefore be enough for securing isolated components rendering.

But that's not true. It would be possible to hijack public controller actions without any authorization in place and request isolated components which are only meant to be rendered within a secured context.

That's why we enforce the usage of the `authorized?` method to make sure, all isolated components take care of their authorization themselves.

If `authorized?` returns `true`, the component will be rendered. If it returns `false`, the component will not be rendered.

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

## Isolated component API

### Authorize

When asynchronously rendering isolated components, these HTTP calls are actually processed by the controller action responsible for the corresponding page rendering. One might think, that the optional authorization and authentication rules of that controller action should therefore be enough for securing isolated component rendering.

But that's not true. It would be possible to hijack public controller actions without any authorization in place and request isolated components which are only meant to be rendered within a secured context.

That's why we enforce the usage of the `authorized?` method to make sure, all isolated components take care of their authorization themselves.

If `authorized?` returns `true`, the component will be rendered. If it returns `false`, the component will not be rendered.

A public isolated component therefore needs an `authorized?` method simply returning `true`.

You can create your own isolated base components with their `authorized` methods for your use cases and thus keep your code DRY.

### Options

All options below are meant to be injected to your isolated component like:

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated defer: 1000, #...
  end
end
```

#### defer

The option defer lets you delay the initial component rendering. If you set defer to a positive integer or `true` the isolate component will not be rendered on initial page load. Instead it will be rendered with an asynchronous request only resolving the isolate component.

If `defer` is set to `true` the asynchronous requests gets triggered as soon as the initial page is loaded.

If `defer` is set to a positive integer \(including zero\) the asynchronous request is delayed by the given amount in ms.

#### rerender\_on

The `rerender_on` options lets you define events on which the component will be rerenderd asynchronously. Events on which the component should be rerendered are specified via a comma seperated string, for example `rerender_on: 'event_one, event_two`.

#### rerender\_delay

The `rerender_delay` option lets you specify a delay in ms after which the asynchronous request is emitted to rerender the component. It can for example be used to smooth out loading animations, preventing flickering in the UI for fast responses.

#### init\_on

With `init_on` you can specify events on which the isolate components gets initialized. Specify events on which the component should be initially rendered via a comma seperated string. When receiving a matching event the isolate component is rendered asynchronously. If you also specified the `defer` option the asynchronous rerendering call will be delayed by the given time in ms of the defer option. If `defer` is set to `true` the rendering will not be delayed.

#### public\_options

You can pass data as a hash to your custom isolate component with the `public_options` option. This data is inside the isolate component accessible via a hash with indifferent access, for example `public_options[:item_id]`. All data contained in the `public_options` will be passed as json to the corresponding Vue.js component, which means this data is visible on the client side as it is rendered in the Vue.js component config. So be careful what data you pass into `public_options`!

Due to the isolation of the component the data needs to be stored on the client side as to encapsulate the component from the rest of the UI. For example: You want to render a collection of models in single components which should be able to rerender asynchronously without rerendering the whole UI. Since we do not rerender the whole UI there is no way the component can know which of the models it should rerender. Therefore passing for example the id in the public\_options hash gives you the possibility to access the id in an async request and fetch the model again for rerendering. See below for examples.

## DOM structure, loading state and animations

Isolated components will be wrapped by a DOM structure like this:

```markup
<div class="matestack-isolated-component-container">
  <div class="matestack-isolated-component-wrapper">
    <div class="matestack-isolated-component-root" >
      hello!
    </div>
  </div>
</div>
```

During async rendering a `loading` class will automatically be applied, which can be used for CSS styling and animations:

```markup
<div class="matestack-isolated-component-container loading">
  <div class="matestack-isolated-component-wrapper loading">
    <div class="matestack-isolated-component-root" >
      hello!
    </div>
  </div>
</div>
```

Additionally you can define a `loading_state_element` within the component class like:

```ruby
class MyIsolated < Matestack::Ui::IsolatedComponent
  def response
    div id: 'my-isolated-wrapper' do
      plain I18n.l(DateTime.now)
    end
  end

  def authorized?
    true
  end

  def loading_state_element
    div class: "loading-spinner" do
      plain "spinner..."
    end
  end
end
```

which will then render to:

```markup
<div class="matestack-isolated-component-container">
  <div class="loading-state-element-wrapper">
    <div class="loading-spinner">
      spinner...
    </div>
  </div>
  <div class="matestack-isolated-component-wrapper">
    <div class="matestack-isolated-component-root" >
      hello!
    </div>
  </div>
</div>
```

and during async rendering request:

```markup
<div class="matestack-isolated-component-container loading">
  <div class="loading-state-element-wrapper loading">
    <div class="loading-spinner">
      spinner...
    </div>
  </div>
  <div class="matestack-isolated-component-wrapper loading">
    <div class="matestack-isolated-component-root" >
      hello!
    </div>
  </div>
</div>
```

## Examples

### Example 1 - Simple Isolate

Create a custom component inheriting from the isolate component

```ruby
class MyIsolated < Matestack::Ui::IsolatedComponent
  def response
    div id: 'my-isolated-wrapper' do
      plain I18n.l(DateTime.now)
    end
  end

  def authorized?
    true
    # check access here using current_user for example when using Devise
    # true means, this isolated component is public
  end
end
```

Register your custom component

```ruby
module ComponentsRegistry
  Matestack::Ui::Core::Component::Registry.register_components(
    my_isolated: MyIsolated
  )
```

And use it on your page

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated
  end
end
```

This will render a h1 with the content welcome and the localized current datetime inside the isolated component. The isolated component gets rendered with the initial page load, because the defer options is not set.

### Example 2 - Simple Deferred Isolated

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated defer: true,
    my_isolated defer: 2000
  end
end
```

By specifying the `defer` option both calls to the custom isolated components will not get rendered on initial page load. Instead the component with `defer: true` will get rendered as soon as the initial page load is done and the component with `defer: 2000` will be rendered 2000ms after the initial page load is done. Which means that the second my\_isolated component will show the datetime with 2s more on the clock then the first one.

### Example 3 - Rerender On Isolate Component

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated rerender_on: 'update_time'
    onclick emit: 'update_time' do
      button 'Update Time!'
    end
  end
end
```

`rerender_on: 'update_time'` tells the custom isolated component to rerender its content asynchronously whenever the event `update_time` is emitted. In this case every time the button is pressed the event is emitted and the isolated component gets rerendered, showing the new timestamp afterwards. In contrast to async components only the `MyIsolated` component is rendered on the server side instead of the whole UI.

### Example 4 - Rerender Isolated Component with a delay

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated rerender_on: 'update_time', rerender_delay: 300
    onclick emit: 'update_time' do
      button 'Update Time!'
    end
  end
end
```

The my\_isolated component will be rerendered 300ms after the `update_time` event is emitted

### Example 5 - Initialize isolated component on a event

```ruby
class Home < Matestack::Ui::Page
  def response
    heading size: 1, text: 'Welcome'
    my_isolated init_on: 'init_time'
    onclick emit: 'init_time' do
      button 'Init Time!'
    end
  end
end
```

With `init_on: 'init_time'` you can specify an event on which the isolated component should be initialized. When you click the button the event `init_time` is emitted and the isolated component asynchronously requests its content.

### Example 6 - Use custom data in isolated components

Like described above it is possible to use custom data in your isolated components. Just pass them as a hash to `public_options` and use them in your isolated component. Be careful, because `public_options` are visible in the raw html response from the server as they get passed to a Vue.js component.

Lets render a collection of models and each of them should rerender when a user clicks a corresponding refresh button. Our model is called `Match`, representing a soccer match. It has an attribute called score with the current match score.

At first we create a custom isolated component.

```ruby
class Components::Match::IsolatedScore < Matestack::Ui::IsolatedComponent

  def prepare
    @match = Match.find_by(public_options[:id])
  end

  def response
    div class: 'score' do
      plain @match.score
    end
    onclick emit: "update_match_#{@match.id}" do
      button 'Refresh'
    end
  end

  def authorized?
    true
    # check access here using current_user for example when using Devise
    # true means, this isolated component is public
  end

end
```

After that we register our new custom component.

```ruby
module ComponentsRegistry
  Matestack::Ui::Core::Component::Registry.register_components(
    match_isolated_score: Components::Match::IsolatedScore
  )
```

Make sure your registry is loaded in your controller. In our case we include our registry in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry
end
```

Now we create our page which will render a list of matches.

```ruby
class Match::Pages::Index < Matestack::Ui::Page
  def response
    Match.all.each do |match|
      match_isolated_score public_options: { id: match.id }, rerender_on: "update_match_#{match.id}"
    end
  end
end
```

This page will render a match\_isolated\_score component for each match. If one of the isolated components gets rerendered we need the id in order to fetch the correct match. Because the server only resolves the isolated component instead of the whole UI it does not know which match exactly is requested unless the client requests a rerender with the match id. This is why `public_options` options are passed to the client side Vue.js component. So if match two should be rerendered the client requests the match\_isolated\_score component with `public_options: { id: 2 }`. With this information our isolated component can fetch the match and rerender itself.

