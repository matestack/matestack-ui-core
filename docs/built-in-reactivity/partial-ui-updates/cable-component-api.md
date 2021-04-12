# Cable Component API

The `cable` component enables us to update the DOM based on events and data pushed via ActionCable without a browser reload.

Please read the [ActionCable Guide](../../integrations/action-cable.md) if you need help setting up ActionCable for your project, and make sure you have set up ActionCable correctly. The following code snippet is crucial to make the `cable` component work correctly:

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
import MatestackUiCore form 'matestack-ui-core';

consumer.subscriptions.create("MatestackUiCoreChannel", {
  //...
  received(data) {
    MatestackUiCore.matestackEventHub.$emit(data.event, data)
  }
});
```

A `cable` component renders a Vue.js driven cable component initially containing content specified by a block.

Imagine something like this:

```ruby
class Page < Matestack::Ui::Page

  def response
    cable id: 'foo' [...] do
      # this block will be rendered as initial content and may be
      # modified on the client side later upon receiving defined events
      DummyModel.all.each do |instance|
        ListComponent.(item: instance)
      end
    end
  end
end
```

```ruby
class ListComponent < Matestack::Ui::Component

  required :item

  def response
    # make sure to define an unique ID on the root element of your component
    # the declared ID may be used later on to update or delete this component on the client side
    div id: "item-#{context.item.id}", class: "row" do
      #...
    end
  end

end
```

Please note: When rendering a list of items, we recommend to use a custom component for each item. This makes it easy to render unique items on the server side and push them via ActionCable to the client. Technically, it is also possible to use another component or a simple html string. Any given html will be used to update the item.

## Parameters

### id - required

Expects an unique string that identifies the `cable` component

### **append\_on**

Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **appended** to the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', append_on: "model_created" do
  DummyModel.all.each do |instance|
    ListComponent.(item: instance)
  end
end
```

In your controller:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "model_created",
  data: ListComponent.(item: @new_model_instance)
})
```

`data` can also be an array of components.

### prepend\_on

Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **prepended** to the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', prepend_on: "model_created" do
  DummyModel.all.each do |instance|
    ListComponent.(item: instance)
  end
end
```

In your controller:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "model_created",
  data: ListComponent.(item: @new_model_instance)
})
```

`data` can also be an array of components.

### replace\_on

Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **replace** the whole current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', replace_on: "model_created" do
  DummyModel.all.each do |instance|
    ListComponent.(item: instance)
  end
end
```

In your controller:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "model_created",
  data: ListComponent.(item: @new_model_instance)
})
```

`data` can also be an array of components.

### update\_on

Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **update** a specific element iditified by its root ID within the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', append_on: "model_created" do
  DummyModel.all.each do |instance|
    ListComponent.(item: instance)
  end
end
```

In your controller:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "model_created",
  data: matestack_component(:list_component, item: @new_model_instance)
})
```

`data` can also be an array of components.

### delete\_on

Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of a string containing the ID will **remove** a specific element identified by its root ID within the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', delete_on: "model_deleted" do
  DummyModel.all.each do |instance|
    ListComponent.(item: instance)
  end
end
```

In your controller:

```ruby
ActionCable.server.broadcast("matestack_ui_core", {
  event: "model_deleted",
  data: "item-#{params[:id]}"
})
```

`data` can also be an Array of ID-strings.

