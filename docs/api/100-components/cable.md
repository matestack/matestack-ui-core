# Matestack Core Component: Cable

The `cable` component enables us to update the DOM based on events and data pushed via ActionCable without browser reload. Please read the [ActionCable Guide](/docs/guides/1000-action_cable/README.md) if you need help setting up ActionCable for your project.

Please read the [ActionCable Guide](/docs/guides/1000-action_cable/README.md) if you need help setting up ActionCable for your project.

Please make sure to setup ActionCable correctly. Esspecially following implementation is important in order to use the `cable` component correctly:

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
      #this block will be rendered as initial content
      #and may be modified on the client later on when receiving defined events
      DummyModel.all.each do |instance|
        list_component item: instance
      end
    end
  end
end
```

with an as `list_component` registered component:

```ruby
class ListComponent < Matestack::Ui::Component

  requires :item

  def response
    #make sure to define a unique ID on the root element of your component
    #this ID may be used to update or delete this component on the client later on
    div id: "item-#{item.id}", class: "row" do
      #...
    end
  end

end
```

Please notice: when rendering a list of items, we recommend to use a custom component for each item. This makes it easy to render unique items on the serverside and push them via ActionCable to the client. But it is possible to also use another component or a html string. Any given html will be used to update the list.


**Required options**

* `id` - Expects a unique string identifying the component

**Optional options**

* `append_on` - Expects a string matching the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **appended** to the current cable component DOM

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

  `data` can also be an Array of components


* `prepend_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **prepended** to the current cable component DOM

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

  `data` can also be an Array of components


* `replace_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **replace** the whole current cable component DOM

  In your app, page or component:

  ```ruby
  cable id: 'foo', replace_on: "model_created" do
    list_component item: instance
  end
  ```

  In your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_created",
    data: matestack_component(:list_component, item: @new_model_instance)
  })
  ```

  `data` can also be an Array of components



* `update_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **update** a specific element iditified by its root ID within the current cable component DOM

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

  `data` can also be an Array of components


* `delete_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of a string containing the ID will **remove** a specific element identified by its root ID within the current cable component DOM

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

  `data` can also be an Array of ID-strings


* Html attributes - all w3c confirm html attributes for div's can be set via options and will be added to the surrounding card div.
