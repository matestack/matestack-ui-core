# Matestack Core Component: Cable

The `cable` component enables us to update the DOM based on events and data pushed via ActionCable without browser reload. Please read the [ActionCable Guide](/docs/guides/1000-action_cable/README.md) if you need help setting up ActionCable for your project.

## `cable(*args, &block)`
----

Returns a vue.js driven cable component initially containing content specified by a block.

When rendering a list of items, make sure to use a custom component for each item. This is mandatory in order to render unique items on the serverside and push them via ActionCable to the client.

Imagine something like this:

```ruby
class MyPage < Matestack::Ui::Page

  def response
    cable id: 'foo' [...] do
      #this block will be rendered as initial content
      #and may be modified on the client later on when receiving defined events
      DummyModel.all.each do |instance|
        my_list_component item: instance
      end
    end
  end
end
```

with a (registered!) custom component:

```ruby
class MyListComponent < Matestack::Ui::Component

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

**Required options**

* `id` - Expects a unique string identifying the component

**Optional options**

* `append_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **appended** to the current cable component DOM

  On your UI class:

  ```ruby
  cable id: 'foo', append_on: "model_created" do
    DummyModel.all.each do |instance|
      my_list_component item: instance
    end
  end
  ```

  On your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_created",
    data: matestack_component(:my_list_component, item: @new_model_instance)
  })
  ```

  `data` can also be an Array of components


* `prepend_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will be **prepended** to the current cable component DOM

  On your UI class:

  ```ruby
  cable id: 'foo', prepend_on: "model_created" do
    DummyModel.all.each do |instance|
      my_list_component item: instance
    end
  end
  ```

  On your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_created",
    data: matestack_component(:my_list_component, item: @new_model_instance)
  })
  ```

  `data` can also be an Array of components


* `replace_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **replace** the whole current cable component DOM

  On your UI class:

  ```ruby
  cable id: 'foo', replace_on: "model_created" do
    my_list_component item: instance
  end
  ```

  On your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_created",
    data: matestack_component(:my_list_component, item: @new_model_instance)
  })
  ```

  `data` can also be an Array of components



* `update_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of HTML will **update** a specific element iditified by its root ID within the current cable component DOM

  On your UI class:

  ```ruby
  cable id: 'foo', append_on: "model_created" do
    DummyModel.all.each do |instance|
      my_list_component item: instance
    end
  end
  ```

  On your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_created",
    data: matestack_component(:my_list_component, item: @new_model_instance)
  })
  ```

  `data` can also be an Array of components


* `delete_on` - Expects a string which matches the event which will be emitted via ActionCable on the serverside. Event payload data in form of a string containing the ID will **remove** a specific element identified by its root ID within the current cable component DOM

  On your UI class:

  ```ruby
  cable id: 'foo', delete_on: "model_deleted" do
    DummyModel.all.each do |instance|
      my_list_component item: instance
    end
  end
  ```

  On your controller:

  ```ruby
  ActionCable.server.broadcast("matestack_ui_core", {
    event: "model_deleted",
    data: "item-#{params[:id]}"
  })
  ```

  `data` can also be an Array of ID-strings


* Html attributes - all w3c confirm html attributes for div's can be set via options and will be added to the surrounding card div.
