# Cable

The `cable` component is designed to asynchronously manipulate its DOM based on ActionCable events triggered on the serverside. Imagine a list of Todos and a `form` below that list. After creating a new Todo, the new list item can be rendered on the serverside and pushed to the `cable` component, which can be configured to pre or append the current list with the new item. Unlike the `async` component, the `cable` component does not request and rerender the whole list after receiving a specific event.

Furthermore you can update or remove items in that list using ActionCable events as well. The `cable` component again will only manipulate the specific DOM elements and not the whole list. This requires more implementation effort but gives you more flexibility and performance while creating reactive UIs compared to the `async` component. As usual, no JavaScript is required at your end in order to implement this sophisticated reactivity. \(Only one time setup as shown below\)

Please read the [ActionCable Guide](1000-action_cable.md) if you need help setting up ActionCable for your project.

Please make sure to setup ActionCable correctly. Esspecially following implementation is important in order to use the `cable` component correctly:

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
consumer.subscriptions.create("MatestackUiCoreChannel", {
  //...
  received(data) {
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

ActionCable pushes data as JSON to the client. You need to make sure to pass this data correctly into the `eventHub` after receiving ActionCable event.

## `cable` vs `async` component

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

## Usage

Imagine a list of Todo Items and a above that list a form to create new Todos, implemented like this:

```ruby
class MyPage < Matestack::Ui::Page

  def response
    form method: :post, path: create_action_rails_route_path do
      form_input key: :title, type: :text
      form_submit do
        button text: "submit"
      end
    end

    Todo.all.each do |instance|
      todo_component todo: instance
    end
  end

end
```

with an as `todo_component` registered component:

```ruby
class TodoComponent < Matestack::Ui::Component

  requires :todo

  def response
    div id: "todo-#{todo.id}", class: "row" do
      div class: "col" do
        plain todo.title
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
    form method: :post, path: create_action_rails_route_path do
      form_input key: :title, type: :text
      form_submit do
        button text: "submit"
      end
    end

    cable id: "my-cable-list", append_on: "new_todo_created" do
      Todo.all.each do |instance|
        todo_component todo: instance
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
      data: matestack_component(:todo_component, todo: @todo)
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
    todo_component todo: instance
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
      data: matestack_component(:todo_component, todo: @todo)
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
    todo_component todo: instance
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
    todo_component todo: instance
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
      icon text: "some-shopping-cart-icon"
      span class: "some-badge", text: count
      transition path: shopping_cart_path do
        button text: "to my cart"
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
    data: matestack_component(:shopping_cart)
  })
  render json: { }, status: :ok
end
```

and on your UI class \(probably your app class\):

```ruby
cable id: "shopping-cart", replace_on: "shopping_cart_updated" do
  shopping_cart
end
```

### Event data as Array

All above shown examples demonstrated how to push a single component or ID to the `cable` component. In all usecases it's also possble to provide an Array of components/ID-strings, e.g.:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "todo_updated",
  data: [
    matestack_component(:todo_component, todo: @todo1),
    matestack_component(:todo_component, todo: @todo2),
  ]
})
```

## Complete documentation

If you want to know all details about the `cable` component checkout its [api documentation](../api/100-components/cable.md)

