# Action Cable

Websockets can easily be integrated into matestack. Matestack uses Rails ActionCable
for this feature.

## Create a Channel on the serverside

`app/channels/matestack_ui_core_channel.rb`

```ruby
class MatestackUiCoreChannel < ApplicationCable::Channel

  def subscribed
    stream_from "matestack_ui_core"
  end

end
```

## Add a Subscription on the client side and link to matestack event hub

`app/assets/javascripts/application.js`

```javascript
//= require cable
//= require matestack-ui-core

App.cable.subscriptions.create("MatestackUiCoreChannel", {
  received(data) {
    MatestackUiCore.matestackEventHub.$emit('MatestackUiCoreChannel', data)
  }
});
```

## Use it on a 'async' component in your response

`app/matestack/pages/your_page.rb`

```ruby
# rerender_on: "comments_changed" makes this div listen to
# a event called "comments_changed"
# if fired by the server (see controller action below), the div gets rerendered
async rerender_on: "comments_changed", id: "unique-id" do
  div id: "tasks" do
    ul class: "mdl-list" do
      @comments.each do |comment|
        plain comment.content
      end
    end
  end
end
```
`app/controllers/your_controller.rb`

```ruby
def create_comment
  comment = DemoComment.create(comment_params)

  unless comment.errors.any?
    broadcast
    render status: 201, json: { message: "comment created" }
  else
    render status: 422, json: { message: "comment creation failed" }
  end
end

protected

def broadcast
  ActionCable.server.broadcast("matestack_ui_core", {
    message: "comments_changed"
  })
end

#...

```
