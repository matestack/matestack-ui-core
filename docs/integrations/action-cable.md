# Action Cable

[ActionCable](https://guides.rubyonrails.org/action_cable_overview.html#server-side-components-connections) seamlessly integrates WebSockets in Ruby on Rails. It allows for real-time communication between your clients and server. ActionCable and matestack can be combined to emit events using matestacks event hub from the server side, for example triggering a rerendering of a chat view if a new message was created on the server.

In this guide we will provide information on how to create channels, consumers and subscriptions to broadcast messages to all subscribed clients or target specific user via user authenticated connections.

## Setup

Create a channel using the rails generator. Run the command `rails generate channel MatestackUiCoreChannel`.

This will create a `app/javascript/channels/matestack_ui_core_channel.js` file where you can setup your subscriptions.

It also generates the corresponding server side `MatestackUiCoreChannel < ApplicationCable::Channel` class.

The `matestack_ui_core_channel.js` is responsible to create a subscription to the "MatestackUiCoreChannel".

All we need to do is to tell this channel that it should trigger an event using the `MatestackUiCore.eventHub` with the received data.

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
import MatestackUiCore from "matestack-ui-core"
import consumer from "./consumer"

consumer.subscriptions.create("MatestackUiCoreChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

We expect the pushed data to include an _event_ key with the name of the event that should be triggered. We also pass the _data_ as event payload to the event emit, giving you the possibility to work with server side send data.

If you do not want to use the rails generator just create the `matestack_ui_core_channel.js` yourself in `app/javascript/channels/` and paste the above code in it.

## Usage

After setting up the client side JavaScript for our action cable we now take a look at how to create server side events to trigger for example rerenderings of `async`/isolated components or show/hide content with the `toggle` component. We will introduce two different types of creating server side events. First broadcasting events to all subscribed clients and secondly sending events to a user by authenticating a connection through a devise user.

### Broadcast

If you've used the generator to setup your channels you already have a `app/channels/matestack_ui_core_channel.rb`. If not create it now. Inside it we define that every subscriber of this channel should stream from the "matestack-ui-core" channel, which means that anything transmitted by a publisher to this channel is direcetly routed to the channel subscribers.

```ruby
class MatestackUiCoreChannel < ApplicationCable::Channel
  def subscribed
    stream_from "matestack_ui_core"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
```

Emitting events from controller actions or elsewhere in your Rails application can be done by calling:

```ruby
ActionCable.server.broadcast('matestack_ui_core', {
  event: 'update'
})
```

### User specific broadcast

You don't always want to broadcast messages to all other clients. You may only want to broadcast to a specific signed in user or multiple users. We now take a look at sending messages via websockets to an authenticated user using devise. Therefore we need to edit our `ApplicationCable::Connection` to identify connections by a current user.

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      if verified_user = env['warden'].user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

Every websocket connection that gets established will be authorized by a `current_user`. We check if a user is signed in by accessing `env['warden'].user` which gets set when a user is successfully authenticated. If `env['warden'].user` is not set we reject the connection.

Now we can create a channel which streams for a specific user, enabling us to send broadcasts to all clients which are signed in with this user.

```ruby
# app/channels/current_user_channel.rb
class CurrentUserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
```

Emitting events for a user can now be done anywhere in your Rails application by calling:

```ruby
# sending to the current user
CurrentUserChannel.broadcast_to(current_user, {
  event: 'update'
})

# sending to a user
CurrentUserChannel.broadcast_to(User.first, {
  event: 'new_message'
})
```

### General broadcast and user specific broadcast

With the above implemented connection authorization in place we will not be able to create connections from clients where no one is signed in. To be able to connect unauthenticated and authenticated users and only give access to authenticated users to specific channels we have to remove the `reject_unauthorized_connection` call from our connection.

```ruby
# app/channels/application_cable/connection.rb
class Connection < ActionCable::Connection::Base
  identified_by :current_user

  def connect
    self.current_user = find_verified_user
  end

  protected

  def find_verified_user
    env['warden'].user
  end

end
```

We then can create two different channels. One allows all clients to subscribe to it and another which only allows signed in users to subscribe to it and handles user specific broadcasting.

First a **public channel** to which every user can subscribe.

```ruby
# app/channels/public_channel.rb
class PublicChannel < ApplicationCable::Channel
  def subscribe
    stream_from 'public'
  end
end
```

Corresponding front end channel subscription.

```javascript
// app/javascript/channels/public_channel.js
import MatestackUiCore from "matestack-ui-core"
import consumer from "./consumer"

consumer.subscriptions.create("PublicChannel", {
  received(data) {
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

Second a **channel only available for signed in users**. We reject clients that try to subscribe but are not signed in by calling `reject` unless a `current_user` is present.

```ruby
# app/channels/private_channel.rb
class PrivateChannel < ApplicationCable::Channel
  def subscribe
    return reject unless current_user
    stream_for current_user
  end
end
```

Corresponding front end channel subscription.

```javascript
// app/javascript/channels/private_channel.js
import MatestackUiCore from "matestack-ui-core"
import consumer from "./consumer"

consumer.subscriptions.create("PrivateChannel", {
  received(data) {
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

**Broadcasting messages**

With these two channels in place and our connection authentication we can now broadcast messages either to a specific clients with a signed in user or to all clients.

Broadcasting to all clients can be achieved with:

```ruby
ActionCable.server.broadcast('public', {
  event: 'update'
})
```

Broadcasting to specific clients with a logged in user can be achieved with:

```ruby
# sending to a user
PrivateChannel.broadcast_to(user, {
  event: 'new_message'
})
```

## Conclusion

Creating channels and connections can be done like you want. To learn more about all the possibilities read Rails Guide about [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html). Important for the use with matestack is to emit events in the JavaScript `received(data)` callback and have a clear structure to determine what the name of the event is which should be emitted. Like shown above we recommend using an `:event` key in your websocket broadcast, which represents the event name that gets emitted through the event hub. You optionally can pass all the received data as payload to that event or also use a specific key. As this is optional you don't need to pass any data to the event emit.

