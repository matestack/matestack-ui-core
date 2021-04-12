# Overview

## `Async` component

Use the `async` component to load or reload content asynchronously depending on events or page initialization. An `async` component can be used to either defer some content on page loads or to rerender a component. For example deferring complex components to increase the initial page load time and render this components asynchronously afterwards. Or rerendering a table after a "reload" button click or rerendering a chat view through action cable events.

The `async` component can be used to load or reload content asynchronously depending on page initialization or events. Simply wrap your content which you want to render asynchronously inside the `async` component. In order to load the content asynchronously after the initial page load use `defer: true` or pass in a number to delay the defer. To reload content you can use `:rerender_on` with an event name, leveraging the event hub, to reload the content if the specified event occurs. For example rerendering a list of todos beneath the form to create todos to instantly show new created objects. Remember events can also be used with action cable, which you could use for "real time" synchronization.

The `async` component is very straightforward in its usage. Every `async` component needs an `:id`, which is necessary for resolving the `async` component and rendering the content in the correct place afterwards. So make sure your ids for async components on the same page are unique. Specifying one of `:defer` or `:rerender_on` or both enables deferred loading and/or rerendering on events. If `:defer` is not configured or false the `async` component will be rendered on page load.

### Deferring content

You can either configure an `async` component to request its content directly after the page load or to delay the request for a given amount of time after the page load. `:defer` expects either a boolean or a integer representing the delay time in milliseconds. If `:defer` is set to `false` the `async` component will be rendered on page load and not deferred. If set to `true` it will request its content directly after the page load.

```ruby
def response
  async id: 'deferred-async', defer: true do
    plain 'Some content rendered after page is loaded.'
  end
end
```

The above `async` component will be rendered asynchronously after page load.

```ruby
def response
  async id: 'delayed-deferred-async', defer: 500 do
    plain 'Some delayed deferred content'
  end
end
```

Specifying `defer: 500` will delay the asynchronous request after page load of the `async` component for 300ms and render the content afterwards.

### Rerendering content

The `async` leverages the event hub and can react to emitted events. If it receives one or more of the with `:rerender_on` specified events it will asynchronously request a rerender of its content. The response will only include the rerendered html of the `async` component which then replaces the current content of the `async`. If you specify multiple events in `:rerender_on` they need to be seperated by a comma.

```ruby
def response
  async id: 'rerendering-async', rerender_on: 'update-time' do
    paragraph DateTime.now
  end
  onclick emit: 'update-time' do
    button text: 'Update time'
  end
end
```

The above snippet renders a paragraph with the current time and a button "Update time" on page load. If the button is clicked a _update-time_ event is emitted. The `async` component wrapping the paragraph receives the event and reacts to it by requesting its rerendered content from the server and replacing its content with the received html. In this case it will rerender after button click and show the updated time.

### Loading animations

An `async` components wraps its content in a special html structure allowing you to create animations while the components gets loaded or rerendered. It appends a loading class to the wrapping elements while the component is loading or rerendering. To learn more about how to animate loading `async` components checkout its [api documentation](async-component-api.md).

{% page-ref page="async-component-api.md" %}

## `Cable` component

The `cable` component is designed to asynchronously manipulate its DOM based on ActionCable events triggered on the serverside. Imagine a list of Todos and a `form` below that list. After creating a new Todo, the new list item can be rendered on the serverside and pushed to the `cable` component, which can be configured to pre or append the current list with the new item. Unlike the `async` component, the `cable` component does not request and rerender the whole list after receiving a specific event.

Furthermore you can update or remove items in that list using ActionCable events as well. The `cable` component again will only manipulate the specific DOM elements and not the whole list. This requires more implementation effort but gives you more flexibility and performance while creating reactive UIs compared to the `async` component. As usual, no JavaScript is required at your end in order to implement this sophisticated reactivity. \(Only one time setup as shown below\)

Please read the [ActionCable Guide](../../integrations/action-cable.md) if you need help setting up ActionCable for your project.

Please make sure to setup ActionCable correctly. Esspecially following implementation is important in order to use the `cable` component correctly:

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
import MatestackUiCore from 'matestack-ui-core';

consumer.subscriptions.create("MatestackUiCoreChannel", {
  //...
  received(data) {
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

ActionCable pushes data as JSON to the client. You need to make sure to pass this data correctly into the `eventHub` after receiving ActionCable event.

### `cable` vs `async` component

`cable` and `async` might seem similar. They indeed can be used for similar use cases - imagine implementing a reactive list of todo items \(using ActiveRecord\) created via a `form` below the list. You can either use `async` or `cable` in order to create that reactive list!

But they work completely differently:

* An `async` component rerenders its whole body via a background HTTP GET request when receiving clientside or serverside events
* A `cable` component may receive serverside \(ActionCable\) events including...
  * serverside rendered HTML which is then used to append, prepend, or replace its body
  * serverside rendered HTML which is then used to update an existing element on the DOM reference by an ID
  * an ID which is then used to remove an existing element from the DOM

Furthermore:

* An `async` does not require any further setup. A matestack UI class and a corresponding controller is all you need to implement.
* A `cable` component requires an ActionCable setup and ActionCable event emission on the serverside.

This means:

* `async` requires less implementation but will always simply request and rerender its whole body and therefore needs more computation time on the serverside
* `cable` requires more implementation but rerenders only very specific parts of UI and therefore needs less computation time on the serverside

If you specifically want to control how to rerender parts of the UI and worry about performance in your specific usecase, use `cable`!

If you just need a simple reactive UI and don't need to optimize for performance in your specific usecase, use `async`!

Imagine a list of Todo Items and a above that list a form to create new Todos, implemented like this:

```ruby
class MyPage < Matestack::Ui::Page

  def response
    matestack_form method: :post, path: create_action_rails_route_path do
      form_input key: :title, type: :text
      button "submit"
    end

    Todo.all.each do |instance|
      TodoComponent.(todo: instance)
    end
  end

end
```

with an as `todo_component` registered component:

```ruby
class TodoComponent < Matestack::Ui::Component

  required :todo

  def response
    div id: "todo-#{context.todo.id}", class: "row" do
      div class: "col" do
        plain context.todo.title
      end
    end
  end

end
```

After form submission, the form resets itself dynamically, but the list will not get updated with the new todo instance. You can now decide, if you want to use `async` or `cable` in order to implement that reactivity. `async` could react to an event emitted by the `form` and simply rerender the whole list without any further implementation. Wrapping the list in a correctly configured `async` component would be enough!

But in this case, we do not want to rerender the whole list every time we submitted the form, because - let's say - the list will be quite long and rerendering the whole list would be getting slow. We only want to add new items to the current DOM without touching the rest of the list. The `cable` component enables you to do exactly this. The principle behind it: After form submission the new component is rendered on the serverside and than pushed to the clientside via ActionCable. The `cable` component receives this event and will than - depending on your configuration - append or prepend the current list on the UI. Implementation would look like this:

### Appending elements

_adding elements on the bottom of the list_

```ruby
class MyPage < Matestack::Ui::Page

  def response
    matestack_form method: :post, path: create_action_rails_route_path do
      form_input key: :title, type: :text
      button "submit"
    end

    cable id: "my-cable-list", append_on: "new_todo_created" do
      Todo.all.each do |instance|
        TodoComponent.(todo: instance)
      end
    end
  end

end
```

and on your controller:

```ruby
def create
  @todo = Todo.create(todo_params)

  unless @todo.errors.any?
    ActionCable.server.broadcast("matestack_ui_core", {
      event: "new_todo_created",
      data: TodoComponent.(todo: @todo)
    })
    # respond to the form POST request (needs to be last)
    render json: { }, status: :created
  end
end
```

Please notice that we recommend to use a component for each list item. With a component for each item it is possible to easily render a new list item within the `create` action and push it to the client. But it is possible to also use another component or a html string. Any given html will be appended to the list.

### Prepending elements

_adding elements on the top of the list_

Prepending works pretty much the same as appending element, just configure your `cable` component like this:

```ruby
cable id: "my-cable-list", prepend_on: "new_todo_created" do
  Todo.all.each do |instance|
    TodoComponent.(todo: instance)
  end
end
```

### Updating elements

_updating existing elements within the list_

Now imagine you want to update elements in your list without browser reload because somewhere else the title of a todo instance was changed. You could use `async` for this as well. Esspecially because `async` can react to serverside events pushed via ActionCable as well. But again: `async` would rerender the whole list... and in our usecase we do not want to this. We only want to update a specific element of the list. Luckily the implementation for this features does not differ from the above explained ones!

Imagine somewhere else the specific todo was updated via a form targeting the following controller action:

```ruby
def update
  @todo = Todo.find(params[:id])
  @todo.update(todo_params)

  unless @todo.errors.any?
    ActionCable.server.broadcast("matestack_ui_core", {
      event: "todo_updated",
      data: TodoComponent.(todo: @todo)
    })
    # respond to the form PUT request (needs to be last)
    render json: { }, status: :ok
  end
end
```

Again, the controller action renders a new version of the component and pushes that to the clientside. Nothing changed here! We only need to tell the `cable` component to react properly to that event:

```ruby
cable id: "my-cable-list", update_on: "todo_updated" do
  Todo.all.each do |instance|
    TodoComponent.(todo: instance)
  end
end
```

Please notice that it is mandatory to have a unique ID on the root element of each list item. The `cable` component will use the ID found in the root element of the pushed component in order to figure out, which element of the current list should be updated. In our example above we used `div id: "todo-#{todo.id}"` as the root element of our `todo_component` used for each element in the list.

### Removing elements

_removing existing elements within the list_

Well, of course we want to be able to remove elements from that list without rerendering the whole list, as `async` would do. The good thing: We can tell the `cable` component to delete elements by ID:

```ruby
cable id: "my-cable-list", delete_on: "todo_deleted" do
  Todo.all.each do |instance|
    TodoComponent.(todo: instance)
  end
end
```

Imagine somewhere else the following destroy controller action was targeted:

```ruby
def destroy
  @todo = Todo.find(params[:id])

  if @todo.destroy
    ActionCable.server.broadcast("matestack_ui_core", {
      event: "todo_deleted",
      data: "todo-#{params[:id]}"
    })
    # respond to the DELETE request (needs to be last)
    render json: { }, status: :deleted
  end
end
```

After deleting the todo instance, the controller action pushes an event via ActionCable, now including just the ID of the element which should be removed. Notice that this ID have to match the ID used on the root element of the component. In our example above we used `div id: "todo-#{todo.id}"` as the root element of our `todo_component` used for each element in the list.

### Replacing the whole component body

Now imagine a context in which the whole `cable` component body should be updated rather than just adding/updating/deleting specific elements of a list. In an online shop app this could be the shopping cart component rendered on the top right. When adding a product to the cart, you might want to update the shopping cart component in order to display the new amount of already included products.

The component may look like this:

```ruby
class ShoppingCart < Matestack::Ui::Component

  def response
    div id: "shopping-cart", class: "some-fancy-styling" do
      icon "some-shopping-cart-icon"
      span count, class: "some-badge"
      transition path: shopping_cart_path do
        button "to my cart"
      end
    end
  end

  def count
    # some logic returning the amount of products in the users cart (saved on serverside)
    current_user.cart.products_count
  end

end
```

Imagine somewhere else the following controller action was targeted when adding a product to the cart:

```ruby
def add_to_cart
  @product = Product.find(params[:id])
  current_user.cart.add(@product) #some logic adding the product to the users cart (saved on serverside)

  ActionCable.server.broadcast("matestack_ui_core", {
    event: "shopping_cart_updated",
    data: ShoppingCart.()
  })
  render json: { }, status: :ok
end
```

and on your UI class \(probably your app class\):

```ruby
cable id: "shopping-cart", replace_on: "shopping_cart_updated" do
  ShoppingCart.()
end
```

### Event data as Array

All above shown examples demonstrated how to push a single component or ID to the `cable` component. In all usecases it's also possble to provide an Array of components/ID-strings, e.g.:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "todo_updated",
  data: [
    ShoppingCart.(todo: @todo1),
    ShoppingCart.(todo: @todo2)
  ]
})
```

{% page-ref page="cable-component-api.md" %}

## Isolated components

Matestacks concept of isolated components has a lot in common with `async` components. Isolated components can be deferred or asynchronously rerendered like `async` components. In the difference to `async` components, isolated components are resolved completetly independent from the rest of the ui. If an isolated component gets rerendered or loaded matestack will directly render this component without touching the app or page. With `async` matestack searches in an app or page which component needs to be rerendered. Therefore executing parts of an app and page whereas isolated components don't.

Isolated components can not be called or used with a block like `async`, instead you need to create a component inheriting from `Matestack::Ui::IsolatedComponent`. Creation of the custom component works similar to other components, except you need to implement an `authorized?` method. As said above isolated components are completly independent and could be called directly via a url, therefore they need custom authorization. More about that later.

Isolated components are perfectly when you have long runnning, complex database queries or business logic which concludes to slow page loads. Use an isolated component with the `:defer` option to keep your page loads fast and present the result to the user asynchronously.

### Differences to simple components

Your isolated components can by design not

* yield components passed in by using a block
* yield slots passed in by using slots
* simply get options injected by surrounding context

They are meant to be `isolated` and resolve all data independently! That's why they can be rendered completely separate from the rest of the UI.

Furthermore isolated components have to be authorized independently. See below.

### Differences to the `async` component

The [`async` component](https://github.com/matestack/matestack-ui-core/tree/829eb2f5a7483ef4b78450a5429589ec8f8123e8/docs/reactive_components/600-isolated/docs/api/100-components/core/async.md) offers pretty similar functionalities enabling you to define asynchronous rendering. The important difference is that rerendering an `async` component requires resolving the whole page on the serverside, which can be performance critical on complex pages. An isolated component bypasses the page and can therefore offer high performance rerendering.

Using the `async` component does NOT require you to create a custom component:

```ruby
class Home < Matestack::Ui::Page
  def response
    h1 'Welcome'
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
    h1 'Welcome'
    MyIsolatedComonent.(rerender_on: "some-event")
  end
end
```

Isolated components should be used on complex UIs where `async` rerendering would be performance critical or you simply wish to create cleaner and more decoupled code.

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

And use it with the `:defer` or `:rerender_on` options which work the same on `async` components.

```ruby
def response
  CurrentTime.(defer: 1000, rerender_on: 'update-time')
end
```

### Deferred loading

You can configure your isolated component to request its content directly after the page load or to delay the request for a given amount of time after the page load instead of being rendered with the page. `:defer` expects either a boolean or a integer representing the delay time in milliseconds. If `:defer` is set to `false` your isolated component will be rendered on page load and not deferred. If set to `true` it will request its content directly after the page load.

```ruby
def response
  CurrentTime.(defer: true)
end
```

The above call to your isolated component will be skipped on page load and the component will request its content asynchronously directly after the page is loaded.

```ruby
def response
  CurrentTime.(defer: 500)
end
```

This will load your isolated component 500ms after the page is loaded.

### Rerendering content

Isolated component leverage the event hub and can react to emitted events. If they receive one or more of the with `:rerender_on` specified events they will asynchronously request a rerender of their content. The server will only render the isolated component, not touching any of the apps or pages. The response will only include the rerendered html of the isolated component which then swaps out its current content with the response. If you specify multiple events in `:rerender_on` they need to be seperated by a comma.

```ruby
def response
  CurrentTime.(rerender_on: 'update-time')
  onclick emit: 'update-time' do
    button 'Update time'
  end
end
```

The above snippet renders our `CurrentTime` isolated component and a button "Update time" on page load. If the button is clicked a _update-time_ event is emitted. Our isolated component receives the event and reacts to it by requesting its rerendered content from the server and replacing its content with the received html. In this case it will rerender after button click and show the updated time.

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

Resolve data from long running queries within the isolated component and defer the rendering of the isolated component in order to speed up initial page load.

```ruby
class BookingsList < IsolatedComponent

  def response
    availabilities.each do |availability|
      paragraph availability.details
    end
  end

  def availabilities
    Booking.some_long_runnning_availability_check
  end
  
  def authorized?
    true
  end

end
```

Deferring such slow parts of your UI speeds up your page load significantly. But remember to always try to improve your query or logic performance as isolated components are not your general solution to fast page loads.

{% page-ref page="isolated-component-api.md" %}



