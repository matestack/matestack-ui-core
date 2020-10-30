# Matestack Core Component: Cable

The `cable` component enables us to update the DOM based on events and data pushed via ActionCable without a browser reload.

Please read the [ActionCable Guide](/docs/guides/1000-action_cable/README.md) if you need help setting up ActionCable for your project, and make sure you have set up ActionCable correctly. The following code snippet is crucial to make the `cable` component work correctly:

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
consumer.subscriptions.create("MatestackUiCoreChannel", {
  //...
  received(data) {
    MatestackUiCore.matestackEventHub.$emit(data.event, data)
  }
});
```

## `cable(*args, &block)`
----

Returns a Vue.js driven cable component initially containing content specified by a block.

Imagine something like this:

```ruby
class Page < Matestack::Ui::Page

  def response
    cable id: 'foo' [...] do
      # this block will be rendered as initial content and may be
      # modified on the client side later upon receiving defined events
      DummyModel.all.each do |instance|
        list_component item: instance
      end
    end
  end
end
```

where the `list_component` is registered like this:

```ruby
class ListComponent < Matestack::Ui::Component

  requires :item

  def response
    # make sure to define an unique ID on the root element of your component
    # the declared ID may be used later on to update or delete this component on the client side
    div id: "item-#{item.id}", class: "row" do
      #...
    end
  end

end
```

Please note: When rendering a list of items, we recommend to use a custom component for each item. This makes it easy to render unique items on the serverside and push them via ActionCable to the client. Technically, it is also possible to use another component or a simple html string. Any given html will be used to update the item.

**Required options**

* `id` - Expects an unique string that identifies the component

**Optional options**

* `append_on` - Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **appended** to the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', append_on: "model_created" do
  DummyModel.all.each do |instance|
    list_component item: instance
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


* `prepend_on` - Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **prepended** to the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', prepend_on: "model_created" do
  DummyModel.all.each do |instance|
    list_component item: instance
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


* `replace_on` - Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **replace** the whole current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', replace_on: "model_created" do
  DummyModel.all.each do |instance|
    list_component item: instance
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


* `update_on` - Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **update** a specific element iditified by its root ID within the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', append_on: "model_created" do
  DummyModel.all.each do |instance|
    list_component item: instance
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


* `delete_on` - Expects a string that matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of a string containing the ID will **remove** a specific element identified by its root ID within the current cable component DOM.

In your app, page or component:

```ruby
cable id: 'foo', delete_on: "model_deleted" do
  DummyModel.all.each do |instance|
    list_component item: instance
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


* `html attributes` - all the canonical [HTML global attributes](https://www.w3schools.com/tags/ref_standardattributes.asp) can be set via options and will be added to the surrounding cable div.
