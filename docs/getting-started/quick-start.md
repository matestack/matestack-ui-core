# Tutorial

## Create a reactive Twitter clone in pure Ruby

In this step-by-step guide, I will show you how to create a Twitter clone in pure Ruby with Matestack, following the great screencasts from Chris McCord [Phoenix LiveView Twitter Clone](https://youtu.be/MZvmYaFkNJI) and Nate Hopkins [Stimulus Reflex Twitter Clone](https://youtu.be/F5hA79vKE_E). We will use the Gem `matestack-ui-core`, which enables us to implement our UI in some Ruby classes rather than writing ERB, HAML or Slim views. Furthermore we don't need to touch JavaScript in order to create reactive UI features, such as updating the DOM without a full browser page reload or syncing multiple web clients through Action Cable!

I've added a small demo showing you what you will be creating in this tutorial:

[![](https://img.youtube.com/vi/Mue5gs6Wtq4/0.jpg)](https://www.youtube.com/watch?v=Mue5gs6Wtq4)

_This guide utilizes the full power of Matestack and uses `matestack-ui-core` as a complete substitute for Rails views. If you only want to create UI components in pure Ruby on existing Rails views, please check out_ [_this guide_](../ui-in-pure-ruby/components/components-on-rails-views.md)

{% hint style="info" %}
The code for this twitter clone tutorial is available in [this repository](https://github.com/matestack/twitter-clone).
{% endhint %}

### Setup

* [x] Create a new Rails app and install some dependencies:

```bash
rails new twitter_clone --webpacker
cd twitter_clone
bundle add matestack-ui-core
yarn add matestack-ui-core
```

* [x] Use Rails scaffolder in order to setup some files:

```bash
rails g scaffold Post body:text likes_count:integer username:string
```

### Model & Database

* [x] Modify generated migration in order to add defaults:

`db/migrate/12345_create_posts.rb`

```ruby
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :body
      t.integer :likes_count, default: 0 # add default
      t.string :username

      t.timestamps
    end
  end
end
```

* [x] Migrate the database:

```bash
rails db:migrate
```

* [x] Add validations and default ordering to the `Post` model:

`app/models/post.rb`

```ruby
class Post < ApplicationRecord

  default_scope { order(created_at: :desc) }

  validates :body, presence: true, allow_blank: false
  validates :username, presence: true

end
```

### Import Matestack's JavaScript

Previously, in version 1.5, Vue and Vuex were imported automatically. Now this must be done manually which is the webpacker way. You can import it in `app/javascript/packs/application.js` or in another pack if you need.

* [x] Modify the JavaScript pack in order to require `matestack-ui-core` and deactivate `turbolinks`:

`app/javascript/packs/application.js`

```javascript
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
// require("turbolinks").start() //remove
require("@rails/activestorage").start()
require("channels")

import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'

import MatestackUiCore from 'matestack-ui-core'

let matestackUiApp = undefined

document.addEventListener('DOMContentLoaded', () => {
  matestackUiApp = new Vue({
    el: "#matestack-ui",
    store: MatestackUiCore.store
  })
})
```

### Application Layout and Views

On `app/views/layouts/application.html.erb` do:

* [x] Add Bootstrap CSS via CDN \(or any other CSS framework\)
* [x] Remove turbolinks attributes \(just for cleanup\)
* [x] Add the `matestack-ui` ID to a DOM element within \(not on!\) the `body` tag

`app/views/layouts/application.html.erb`

```markup
<!DOCTYPE html>
<html>
  <head>
    <title>TwitterClone</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <meta charset="utf-8">

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

    <%= stylesheet_link_tag 'application', media: 'all' %>
    <%= javascript_pack_tag 'application' %>
  </head>

  <body>
    <div id="matestack-ui">
      <%= yield %>
    </div>
  </body>
</html>
```

* [x] Delete all generated `app/views/posts` views - we don't need them!

### Controller

* [x] Add Matestack's helper to your application controller:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base

  include Matestack::Ui::Core::Helper

end
```

* [x] Remove not required code from the generated controller:

`app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:username, :body)
  end

end
```

### Matestack App and Pages

* [x] Add a `matestack` folder and create a Matestack app and a Matestack `Post` index page file:

```bash
mkdir -p app/matestack/twitter_clone
touch app/matestack/twitter_clone/app.rb
mkdir -p app/matestack/twitter_clone/pages/posts
touch app/matestack/twitter_clone/pages/posts/index.rb
```

* [x] Add some basic code to the files:

`app/matestack/twitter_clone/app.rb`

```ruby
class TwitterClone::App < Matestack::Ui::App

  def response
    div class: "container" do
      heading size: 1, text: "Twitter Clone", class: "mb-5"
      yield if block_given?
    end
  end

end
```

`app/matestack/twitter_clone/pages/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    @posts.each do |post|
      div class: "mb-3 p-3 rounded shadow-sm" do
        heading size: 5 do
          plain post.username
          small text: post.created_at.strftime("%d.%m.%Y %H:%M")
        end
        paragraph text: post.body
      end
    end
  end

end
```

### Add Matestack to the Controller

* [x] Reference Matestack's app and page on the controller and `index` action:

`app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController

  matestack_app TwitterClone::App # add this

  # GET /posts
  # GET /posts.json
  def index
    # @posts = Post.all
    render TwitterClone::Pages::Posts::Index # add this
  end

  # ...
end
```

**Test the current state**

* [x] Fire up the Rails server and see what we got at this point \(heads up: we still need a little more code yet\)

```bash
rails s
```

* [x] Navigate to `localhost:3000/posts`

You should see the heading "Twitte Clone" and that's it. We don't have any posts in our database, so we need a `form` to create one!

### Add a Reactive Form

* [x] Add a reactive `form` to the index page
* [x] Use the `form_config_helper` method returning a config hash in order to inject a hash into the form without polluting the code
* [x] Refactor the code by using methods serving as 'partials'

`app/matestack/twitter_clone/pages/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  def post_form_partial
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 4, text: "New Post", class: "mb-3"
      matestack_form form_config_helper do
        div class: "mb-3" do
          form_input key: :username, type: :text, placeholder: "Username", class: "form-control"
        end
        div class: "mb-3" do
          form_textarea key: :body, placeholder: "What's up?", class: "form-control"
        end
        div class: "mb-3" do
          button 'submit', type: :submit, class: "btn btn-primary", text: "Post!"
        end
      end
    end
  end

  def form_config_helper
    {
      for: Post.new, path: posts_path, method: :post,
      # optional: in order to map Bootstrap's CSS classes, you can adjust the form error rendering like so:
      errors: {wrapper: {tag: :div, class: 'invalid-feedback'}, input: {class: 'is-invalid'}}
    }
  end

  def post_list_partial
    @posts.each do |post|
      div class: "mb-3 p-3 rounded shadow-sm" do
        heading size: 5 do
          plain post.username
          small text: post.created_at.strftime("%d.%m.%Y %H:%M")
        end
        paragraph text: post.body
      end
    end
  end

end
```

* [x] Slightly change the response within the `create` action in order to support the new form:

`app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController

  # ...

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    # respond_to do |format|
    #   if @post.save
    #     format.html { redirect_to @post, notice: 'Post was successfully created.' }
    #     format.json { render :show, status: :created, location: @post }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @post.errors, status: :unprocessable_entity }
    #   end
    # end

    if @post.save
      render json: {
        message: 'Post was successfully created.'
      }, status: :created
    else
      render json: {
        errors: @post.errors,
        message: 'Post could not be created.'
      }, status: :unprocessable_entity
    end
  end

  # ...

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`

You should see a basic index page with a form at the top. When submitting the form without any values, ActiveRecord errors should appear below the input fields without a browser page reload. When submitting valid data, the form should reset automatically without a browser page reload, but you will still have to reload the browser in order to see the new post!

To get that reactivity to work, we need make use of the `async` component.

### Add Matestack's Async Component

* [x] Add `success: {emit: "submitted"}` to the form config
* [x] Wrap the `post_list_partial` with an `async`, configured to rerender when the event `submitted` is received

`app/matestack/twitter_clone/pages/posts/index.rb`

```ruby
# ...

def form_config_helper
  {
    for: Post.new, path: posts_path, method: :post,
    errors: {
      wrapper: {tag: :div, class: 'invalid-feedback'},
      input: {class: 'is-invalid'}
    },
    success: {emit: "submitted"}
  }
end

def post_list_partial
  async rerender_on: "submitted", id: "post-list" do
    @posts.each do |post|
      div class: "mb-3 p-3 rounded shadow-sm" do
        heading size: 5 do
          plain post.username
          small text: post.created_at.strftime("%d.%m.%Y %H:%M")
        end
        paragraph text: post.body
      end
    end
  end
end

# ...
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`

Cool! Now you should see the list automatically updating itself after form submission without a browser page reload! And we didn't have to write any JavaScript. Just two lines of simple Ruby code! How cool is that?

Now we need to add some `action` components in order to "like" the posts.

### Enable "likes"

* [x] Add the `like` route:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :posts do
    member do
      put 'like', to: 'posts#like'
    end
  end
end
```

* [x] Add the `like` action on the controller:

`app/controllers/posts_controller.rb`

```ruby
# ...

# PUT /posts/1/like
def like
  @post = Post.find params[:id]
  @post.increment(:likes_count)

  if @post.save
    render json: {
      message: 'Post was successfully liked.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be liked.'
    }, status: :unprocessable_entity
  end
end

# ...
```

* [x] Refactor the post\_list\_partial and use another method, defining the post itself
* [x] Add the `like` action component and emit a post-specific event
* [x] Wrap the post in an async, configured to rerender itself on the event emitted by the action component

`app/matestack/twitter_clone/pages/index.rb`

```ruby
# ...

def post_list_partial
  async rerender_on: "submitted", id: "post-list" do
    @posts.each do |post|
      post_partial(post)
    end
  end
end

def post_partial(post)
  async rerender_on: "liked_post_#{post.id}", id: "post-#{post.id}" do
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 5 do
        plain post.username
        small text: post.created_at.strftime("%d.%m.%Y %H:%M")
      end
      paragraph text: post.body, class: "mb-5"
      action path: like_post_path(post), method: :put, success: {emit: "liked_post_#{post.id}"} do
        button class: "btn btn-light" do
          plain "Like (#{post.likes_count})"
        end
      end
    end
  end
end

# ...
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`

When you click the "Like" button on a post, you will see the counter increasing without a full page reload! Again: Reactivity without any JavaScript!

Great! We added a reactive form and reactive actions. We can now add some reactive feedback on top using the toggle component!

### Add Reactive Feedback Using the `toggle` Component

* [x] Add failure event submission to the form config like: `failure: {emit: "form_failed"},`
* [x] Add a `toggle` component in order to render the success message for 5 seconds
* [x] Add a `toggle` component in order to render the failure message for 5 seconds

`app/matestack/twitter_clone/pages/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  def post_form_partial
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 4, text: "New Post", class: "mb-3"
      matestack_form form_config_helper do
        # ...
      end
    end
    toggle show_on: "submitted", hide_after: 5000 do
      div class: "container fixed-bottom w-100 bg-success text-white p-3 rounded-top" do
        heading size: 4, text: "Success: {{ event.data.message }}"
      end
    end
    toggle show_on: "form_failed", hide_after: 5000 do
      div class: "container fixed-bottom w-100 bg-danger text-white p-3 rounded-top" do
        heading size: 4, text: "Error: {{ event.data.message }}"
      end
    end
  end

  def form_config_helper
    {
      for: Post.new, path: posts_path, method: :post,
      success: {emit: "submitted"},
      failure: {emit: "form_failed"},
      errors: {wrapper: {tag: :div, class: 'invalid-feedback'}, input: {class: 'is-invalid'}}
    }
  end

  # ...

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`

Great! Now we get instant feedback after performing successful or unsuccessful form submissions! And still no line of JavaScript involved! The same approach would work for our actions, but we do not want to have that feedback after performing the actions in this example!

All of the above described reactivity only applies for one client. A second user wouldn't see the new post, unless he reloads his browser page. But of course, we want to sync all connected clients! It's time to integrate ActionCable!

### Integrate Action Cable

* [x] Generate an ActionCabel channel

```bash
rails generate channel MatestackUiCoreChannel
```

* [x] Adjust the generated files like:

`app/javascript/channels/matestack_ui_core_channel.js`

```javascript
import consumer from "./consumer"
import MatestackUiCore from 'matestack-ui-core'

consumer.subscriptions.create("MatestackUiCoreChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    MatestackUiCore.eventHub.$emit(data.event, data)
  }
});
```

`app/channels/matestack_ui_core_channel.rb`

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

* [x] Broadcast the `cable__created_post` event from the `create` action on the posts controller
* [x] Broadcast the `cable__liked_post_xyz` event from the `like` action on the posts controller

`app/controllers/posts_controller.rb`

```ruby
# ...

# PUT /posts/1/like
def like
  @post = Post.find params[:id]
  @post.increment(:likes_count)

  if @post.save
    ActionCable.server.broadcast('matestack_ui_core', {
      event: "cable__liked_post_#{@post.id}"
    })
    render json: {
      message: 'Post was successfully liked.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be liked.'
    }, status: :unprocessable_entity
  end
end

# POST /posts
def create
  @post = Post.new(post_params)

  if @post.save
    ActionCable.server.broadcast('matestack_ui_core', {
      event: 'cable__created_post'
    })
    render json: {
      message: 'Post was successfully created.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be created.'
    }, status: :unprocessable_entity
  end
end

# ...
```

* [x] Adjust the event name used for list rerendering

`app/matestack/twitter_clone/pages/posts/index.rb`

```ruby
# ...

def form_config_helper
  {
    for: Post.new, path: posts_path, method: :post,
    success: {emit: "submitted"},
    failure: {emit: "form_failed"},
    errors: {wrapper: {tag: :div, class: 'invalid-feedback'}, input: {class: 'is-invalid'}}
  }
end

def post_list_partial
  async rerender_on: "cable__created_post", id: "post-list" do
    @posts.each do |post|
      post_partial(post)
    end
  end
end

# ...
```

* [x] Add the adjusted event names to the per-post async config
* [x] Remove the success event emits from the actions - the event for per post-rerendering will be pushed from the server now

`app/matestack/twitter_clone/pages/index.rb`

```ruby
# ...

def post_list_partial
  @posts.each do |post|
    post_partial(post)
  end
end

def post_partial post
  # async rerender_on: "liked_post_#{post.id}", id: "post-#{post.id}" do
  async rerender_on: "cable__liked_post_#{post.id}", id: "post-#{post.id}" do
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 5 do
        plain post.username
        small text: post.created_at.strftime("%d.%m.%Y %H:%M")
      end
      paragraph text: post.body, class: "mb-5"
      # action path: like_post_path(post), method: :put, success: {emit: "liked_post_#{post.id}"} do
      action path: like_post_path(post), method: :put do
        button class: "btn btn-light" do
          plain "Like (#{post.likes_count})"
        end
      end
    end
  end
end

# ...
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts` on one browser tab
* [x] Navigate to `localhost:3000/posts` on another browser tab
* [x] Place the browser tabs side by side, so that you can see both browser tab contents
* [x] Use the form and the actions on one browser tab and see how the content on the other tab gets updated and vice versa

Wow! We just had to copy and paste a JavaScript snippet once in order to integrate ActionCable, broadcast an event from the controller action and without any more added complexity, we get synced clients, implemented in pure Ruby! Fantastic!

We will take a short break before adding the next cool reactivity feature and refactor a little bit! Matestack encourages you to create a readable and maintainable UI implemetation. Therefore we will move some complexity from the current index page to a self contained Matestack component!

### Create a Matestack Component

* [x] Create a components folder within the matestack folder

```bash
mkdir -p app/matestack/components
touch app/matestack/components/post.rb
```

* [x] Move code from the index page to the new component
* [x] adjust references to the given post parameter to be called as a method of the context object \(`context.post.id`\)

`app/matestack/components/post.rb`

```ruby
class Components::Post < Matestack::Ui::Component

  requires :post

  def response
    # copied from the index page
    async rerender_on: "cable__liked_post_#{context.post.id}", id: "post-#{context.post.id}" do
      div class: "mb-3 p-3 rounded shadow-sm" do
        heading size: 5 do
          plain context.post.username
          small text: context.post.created_at.strftime("%d.%m.%Y %H:%M")
        end
        paragraph text: context.post.body, class: "mb-5"
        action path: like_post_path(context.post), method: :put do
          button class: "btn btn-light" do
            plain "Like (#{context.post.likes_count})"
          end
        end
      end
    end
  end

end
```

* [x] Adjust the index page in order to use the new component

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def post_list_partial
    async rerender_on: "submitted", id: "post-list" do
      @posts.each do |post|
        # post_partial(post)
        Components::Post.(post: post)
      end
    end
  end

  # def post_partial post
  #   async rerender_on: "cable__liked_post_#{post.id}", id: "post-#{post.id}" do
  #     div class: "mb-3 p-3 rounded shadow-sm" do
  #       heading size: 5 do
  #         plain post.username
  #         small text: post.created_at.strftime("%d.%m.%Y %H:%M")
  #       end
  #       paragraph text: post.body, class: "mb-5"
  #       action path: like_post_path(post), method: :put do
  #         button class: "btn btn-light" do
  #           plain "Like (#{post.likes_count})"
  #         end
  #       end
  #     end
  #   end
  # end

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`

Everything should be the same! We just refactored some code in order to better manage complexity.

### Component Registry

Components can be invoked as we have done above \(`Components::Post.(post: post)`\). But sometimes the namespace can get a little long and in the interest of keeping our code beautiful, we can register our components so we can call them like:

```ruby
  # ...

  def post_list_partial
    async rerender_on: "submitted", id: "post-list" do
      @posts.each do |post|
        # post_partial(post)
        post_component post: post
      end
    end
  end

  # ...
```

Let's refactor and set up a component registry and register our component.

* [x] Create a component registry file

```bash
touch app/matestack/components/registry.rb
```

* [x] Register the new component

`app/matestack/components/registry.rb`

```ruby
module Components::Registry

  def post_component(post:)
    Components::Post.(post: post)
  end

end
```

* [x] Adjust the index page to include the Components::Registry
* [x] Adjust the index page in order to use the component in the new way

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  include Components::Registry

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def post_list_partial
    async rerender_on: "submitted", id: "post-list" do
      @posts.each do |post|
        # post_partial(post)
        post_component post: post
      end
    end
  end

  # ...

end
```

**Test the current state again**

* [x] Navigate to `localhost:3000/posts`

Everything should be the same after this small refactoring.

### The Cable Component

Now we will cover the last topic of this guide:

As described before, the `async` rerenders it's whole body. The `async` wrapping the whole post list therefore rerenders ALL posts. If our list of posts grows, the performance of the rerendering will decrease. In a lot of usecases, this will not be an issue since the UI is not too big/too complex. So go ahead and use `async` everywhere you're not rerendering big or complex UIs and enjoy the simplicity of that rerendering approach!

But now imagine, your post list will be too big at some point. We should switch the reactivity approach to a more granular one. Let's use the `cable` component alongside our already added ActionCable introduction and reuse pretty much all written code!

### Use the `cable` Component For List Rerendering

* [x] Use the `cable` instead of the `async` component

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def post_list_partial
    # async rerender_on: "submitted", id: "post-list" do
    cable prepend_on: "cable__created_post", id: "post-list" do
      @posts.each do |post|
        post_component post: post
      end
    end
  end

end
```

* [x] Adjust the ActionCable broadcast on the `create` action on the post controller

`app/controllers/posts_controller.rb`

```ruby
# ...

# POST /posts
def create
  @post = Post.new(post_params)

  if @post.save
    ActionCable.server.broadcast('matestack_ui_core', {
      event: 'cable__created_post',
      data: post_component(post: @post) # add this line
    })
    render json: {
      message: 'Post was successfully created.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be created.'
    }, status: :unprocessable_entity
  end
end

# ...
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Post something!

You probably don't realize any difference on the UI, but now ONLY the fresh post will be rendered on the server and pushed to the `cable` component mounted in the browser. The `cable` component is configured to `prepend` \(put on top\) everything pushed from the server on the `cable__created_post` event. This reactivity approach is now already much more scalable in a context of big/complex UI rerendering.

The `cable` component can `prepend`, `append`, `update` and `delete` elements within its body or `replace` its whole body with something pushed from the server. We want to use the `update` feature in order to rerender a specific post when liked:

### Adjust the `cable` Component for Post Rerendering

* [x] Add the `update_on` config to the `cable` config

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def post_list_partial
    # cable prepend_on: "cable__created_post", id: "post-list" do
    cable prepend_on: "cable__created_post", update_on: "cable__liked_post", id: "post-list" do
      @posts.each do |post|
        post_component post: post
      end
    end
  end

end
```

* [x] Remove the `async` and add an ID to the root element

`app/matestack/components/post.rb`

```ruby
class Components::Post < Matestack::Ui::Component

  requires :post

  def response
    # async rerender_on: "cable__liked_post_#{post.id}", id: "post-#{context.post.id}" do
      div class: "mb-3 p-3 rounded shadow-sm", id: "post-#{context.post.id}" do
        heading size: 5 do
          plain context.post.username
          small text: context.post.created_at.strftime("%d.%m.%Y %H:%M")
        end
        paragraph text: context.post.body, class: "mb-5"
        action path: like_post_path(context.post), method: :put do
          button class: "btn btn-light" do
            plain "Like (#{context.post.likes_count})"
          end
        end
      end
    # end
  end

end
```

* [x] Adjust the ActionCable broadcast on the `like` action on the post controller

`app/controllers/posts_controller.rb`

```ruby
# ...

# PUT /posts/1/like
def like
  @post = Post.find params[:id]
  @post.increment(:likes_count)

  if @post.save
    ActionCable.server.broadcast('matestack_ui_core', {
      # event: "cable__liked_post_#{@post.id}"
      # no id required in the event name, the cable component will figure out which post
      # should be updated using the root element ID of the pushed component
      event: "cable__liked_post", # change the event name
      data: post_component(post: @post) # add this line
    })
    render json: {
      message: 'Post was successfully liked.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be liked.'
    }, status: :unprocessable_entity
  end
end

# POST /posts
def create
  @post = Post.new(post_params)

  if @post.save
    ActionCable.server.broadcast('matestack_ui_core', {
      event: 'cable__created_post',
      data: post_component(post: @post)
    })
    render json: {
      message: 'Post was successfully created.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be created.'
    }, status: :unprocessable_entity
  end
end

# ...
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Like something on both browser tabs

Again: you probably don't realize any difference on the UI, but now ONLY the updated post will be rendered on the server and pushed to the `cable` component mounted in the browser.

The `cable` component is configured to `update` the component pushed from the server on the `cable__liked_post` event. The `cable` component then reads the ID of the root element of the pushed component, looks for that ID within it's body and updates this element with the pushed component.

Now, we're rerendering the list and its elements completely with the `cable` component. As described, this is an ALTERNATIVE approach to the introduced `async` component approach. The `cable` component requires a bit more implementation and brain power but makes our reactivity more scalable. Use the `cable` component wherever you think `async` would be too slow at some point!

Ok, let's lazy load the list of posts in order to speed up initial page load when reading the posts from the database and rendering them gets "too slow" at some point. Take a deep breath: We will use `async` and `cable` together now!

Relax, it's super simple:

### Lazy Load the Post List With Async's `defer` Feature

* [x] Wrap an `async` component around the `cable` component
* [x] Configure this `async` to defer its rendering
* [x] Move the ActiveRecord query out of the `prepare` method into a helper method

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  # def prepare
  #   @posts = Post.all
  # end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def posts
    Post.all
  end

  def post_list_partial
    async defer: true, id: "deferred-post-list" do
      cable prepend_on: "cable__created_post", update_on: "cable__liked_post", id: "post-list" do
        # @posts.each do |post|
        posts.each do |post|
          post_component post: post
        end
      end
    end
  end

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Check the browsers network monitor and watch how a subsequent HTTP GET call resolves the posts list
* [x] Change `defer: true` to `defer: 1000` and see, how the subsequent call is deferred for 1000 milliseconds now

That was easy, right? The `async` requested its content right after the page was loaded. We moved the ActiveRecord query out of the `prepare` method out of following reason: When rendering a Matestack page/component, the `prepare` method is always called. This means, the ActiveRecord query is performed on the initial page load although we don't need the data yet. Matestacks rendering mechanism stops rendering components which are wrapped in an `async defer` component on initial page load and only renders them, when they are explicitly requested in a subsequent HTTP call. Therefore we should take care of calling the ActiveRecord query only from within the deferred block. In our example we accomplish this by calling the helper method `posts` instead of using the instance variable `@posts`, formerly resolved in the `prepare` method.

Using this approach, it is super simple to speed up initial page loads without adding complexity or JavaScript to your code! Awesome!

Want some sugar? How about adding a CSS animation while lazy loading the post list?

```bash
mkdir -p app/javascript/packs/stylesheets
touch app/javascript/packs/stylesheets/application.scss
```

`app/javascript/packs/stylesheets/application.scss`

```css
// Async loading state
.matestack-async-component-container{

  opacity: 1;
  transition: opacity 0.2s ease-in-out;

  &.loading {
    opacity: 0;
  }

}
```

`app/javascript/packs/application.js`

```javascript
// add this line
import "./stylesheets/application.scss";
```

* [x] Refresh the browser and enjoy the fade effect!

Speaking of fade effects: Let's add a second page in order to show, how you can use Matestacks app and `transition` component in order to implement dynamic page transitions without full browser page reload and without adding any JavaScript!

### Implement Dynamic Page Transitions

We will create a profile page in order to save the username in a session cookie rather than asking for the username on the post form! Obviously, you would use proper user management via something like `devise` in a real world example!

* [x] Add an view helper method in order to access the session cookie from a Matestack page

```bash
touch app/helpers/cookie_helper.rb
```

`app/helpers/cookie_helper.rb`

```ruby
module CookieHelper

  def current_username
    cookies[:username]
  end

end
```

* [x] Remove the username input from the post form
* [x] Remove the toggle components from the post index page; we will add them to the app in a moment, enabling the new profile page to trigger them as well!
* [ ] `app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def response
    post_form_partial
    post_list_partial
  end

  private

  def post_form_partial
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 4, text: "New Post", class: "mb-3"
      matestack_form form_config_helper do
        # div class: "mb-3" do
        #   form_input key: :username, type: :text, placeholder: "Username", class: "form-control"
        # end
        div class: "mb-3" do
          form_input key: :body, type: :text, placeholder: "What's up?", class: "form-control"
        end
        div class: "mb-3" do
          form_submit do
            button type: :submit, class: "btn btn-primary", text: "Post!"
          end
        end
      end
    end
    # toggle show_on: "submitted", hide_after: 5000 do
    #   div class: "container fixed-bottom w-100 bg-success text-white p-3 rounded-top" do
    #     heading size: 4, text: "Success: {{ event.data.message }}"
    #   end
    # end
    # toggle show_on: "form_failed", hide_after: 5000 do
    #   div class: "container fixed-bottom w-100 bg-danger text-white p-3 rounded-top" do
    #     heading size: 4, text: "Error: {{ event.data.message }}"
    #   end
    # end
  end

  # ...

end
```

* [x] Adjust the create action in order to use the cookie instead of a user input

`app/matestack/twitter_clone/posts/index.rb`

```ruby
# ...

# POST /posts
def create
  @post = Post.new(post_params)

  @post.username = cookies[:username] # add this

  # check if the username is already set
  if cookies[:username].blank?
    # if not complain!
    render json: {
      message: 'No username given!'
    }, status: :unprocessable_entity
  else
    # if yes, perform the code we already got
    if @post.save
      ActionCable.server.broadcast('matestack_ui_core', {
        event: 'cable__created_post',
        data: post_component(post: @post)
      })
      render json: {
        message: 'Post was successfully created.'
      }, status: :created
    else
      render json: {
        errors: @post.errors,
        message: 'Post could not be created.'
      }, status: :unprocessable_entity
    end
  end

end

# ...
```

* [x] Add a second page

```bash
mkdir -p app/matestack/twitter_clone/pages/profile
touch app/matestack/twitter_clone/pages/profile/edit.rb
```

* [x] Add some code to the profile edit page

`app/matestack/twitter_clone/pages/profile/edit.rb`

```ruby
class TwitterClone::Pages::Profile::Edit < Matestack::Ui::Page

  def response
    div class: "mb-3 p-3 rounded shadow-sm" do
      heading size: 4, text: "Your Profile", class: "mb-3"
      matestack_form form_config_helper do
        div class: "mb-3" do
          form_input key: :username, type: :text, placeholder: "Username", class: "form-control", init: current_username
        end
        div class: "mb-3" do
          button 'submit', type: :submit, class: "btn btn-primary", text: "Save!"
        end
      end
    end
  end

  private

  def form_config_helper
    {
      for: :profile, path: profile_update_path, method: :put,
      success: {emit: "submitted"},
      failure: {emit: "form_failed"},
      errors: {wrapper: {tag: :div, class: 'invalid-feedback'}, input: {class: 'is-invalid'}}
    }
  end

end
```

* [x] Add the `profile` routes:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :posts do
    member do
      put 'like', to: 'posts#like'
    end
  end
  scope :profile, as: :profile do
    get 'edit', to: 'profile#edit'
    put 'update', to: 'profile#update'
  end
end
```

* [x] Add the `profile` controller:

```bash
touch app/controllers/profile_controller.rb
```

`app/controllers/profile_controller.rb`

```ruby
class ProfileController < ApplicationController

  matestack_app TwitterClone::App

  # GET /profile/edit
  def edit
    render TwitterClone::Pages::Profile::Edit
  end

  # PUT /profile/update
  def update
    if profile_params[:username].blank?
      render json: {
        message: 'Profile could not be updated.',
        errors: {username: ["can't be blank!"]}
      }, status: :unprocessable_entity
    else
      cookies[:username] = profile_params[:username]
      render json: {
        message: 'Profile was successfully updated.'
      }, status: :created
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(:username)
  end

end
```

* [x] Add `transition` components to the app
* [x] Add the `toggle` components from the post index page to the app, this way they can be triggered from all pages

`app/matestack/twitter_clone/app.rb`

```ruby
class TwitterClone::App < Matestack::Ui::App

  def response
    div class: "container" do
      # heading size: 1, text: "Twitter Clone", class: "mb-5"
      # yield if block_given?
      heading size: 1, text: "Twitter Clone"
      transition path: posts_path do
        button class: "btn btn-light", text: "Timeline"
      end
      transition path: profile_edit_path do
        button class: "btn btn-light", text: "Your Profile"
      end
      div class: "mt-5" do
        yield if block_given?
      end
      # add the toggle components here, this way all pages are able to trigger them!
      toggle show_on: "submitted", hide_after: 5000 do
        div class: "container fixed-bottom w-100 bg-success text-white p-3 rounded-top" do
          heading size: 4, text: "Success: {{ event.data.message }}"
        end
      end
      toggle show_on: "form_failed", hide_after: 5000 do
        div class: "container fixed-bottom w-100 bg-danger text-white p-3 rounded-top" do
          heading size: 4, text: "Error: {{ event.data.message }}"
        end
      end
    end
  end

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Click on "Your Profile"
* [x] See how the page is updated without a full browser page reload
* [x] See how the url changed according to our routes and realize that we're using plain Rails routing for page transitions
* [x] Enter a username there
* [x] Realize, that we used the form for a non ActiveRecord data structure
* [x] Click on "Timeline"
* [x] Again: see how the page is updated without a full browser page reload, maybe even inspect your browsers network monitor ;\)
* [x] Post something and enjoy not to enter a username anymore \(use a private tab if you want to act as a different user!\)

Great, we just added a second page and added some `transition` components to our app and without further effort, we implemented dynamic page transitions without touching any JavaScript. The `transition` component triggered the app to request the desired page at the server targeting the appropriate controller action through Rails routing and adjusted the DOM where we placed the `yield if block_given?` on our app!

And you know what: let's add some CSS animations!

* [x] Add some basic animations to your stylesheets \(SCSS\)

`app/javascript/packs/stylesheets/application.scss`

```css
// Async loading state
.matestack-async-component-container{

  opacity: 1;
  transition: opacity 0.2s ease-in-out;

  &.loading {
    opacity: 0;
  }

}

// Page loading state
.matestack-page-container{

  .matestack-page-wrapper {
    opacity: 1;
    transition: opacity 0.2s ease-in-out;

    &.loading {
      opacity: 0;
    }
  }

}
```

* [x] Add delays to the `transition` components; otherwise we probably won't see the animations!

`app/matestack/twitter_clone/app.rb`

```ruby
class TwitterClone::App < Matestack::Ui::App

  def response
    div class: "container" do
      heading size: 1, text: "Twitter Clone"
      # transition path: posts_path do
      transition path: posts_path, delay: 300 do
        button class: "btn btn-light", text: "Timeline"
      end
      # transition path: profile_edit_path do
      transition path: profile_edit_path, delay: 300 do
        button class: "btn btn-light", text: "Your Profile"
      end
      div class: "mt-5" do
        yield if block_given?
      end
    end
  end

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Click on the transition components
* [x] Enjoy the fade effects once again :\)

And now, let's do something that isn't possible in Twitter: Editing. Tweets. Inline. In pure Ruby! \(Just because it's nice to showcase that\)

### Inline Editing

* [x] Add an edit form
* [x] Add an `onclick` component emit an event indicating that we want to show the form now
* [x] Wrap your code into toggle components, switching the currently visible content
* [x] Adjust the cable component to react to an additional event

`app/matestack/components/post.rb`

```ruby
class Components::Post < Matestack::Ui::Component

  requires :post

  def response
    div class: "mb-3 p-3 rounded shadow-sm", id: "post-#{context.post.id}" do
      heading size: 5 do
        plain context.post.username
        small text: context.post.created_at.strftime("%d.%m.%Y %H:%M")
      end
      toggle hide_on: "edit-post-#{context.post.id}", show_on: "updated", init_show: true do
        show_partial
      end
      toggle show_on: "edit-post-#{context.post.id}", hide_on: "updated" do
        edit_partial
      end
      # paragraph text: context.post.body, class: "mb-5"
      # action path: like_post_path(context.post), method: :put do
      #   button class: "btn btn-light" do
      #     plain "Like (#{context.post.likes_count})"
      #   end
      # end
    end
  end

  private

  def show_partial
    paragraph text: context.post.body, class: "mb-5"
    action path: like_post_path(context.post), method: :put do
      button class: "btn btn-light" do
        plain "Like (#{context.post.likes_count})"
      end
    end
    # onclick emits an event triggering the toggle components to show/hide
    # we use Bootstraps "d-inline" utility class here because onclick renders
    # a block element (will be changed to an inline element in a future release)
    onclick emit: "edit-post-#{context.post.id}", class: "d-inline" do
      button class: "btn btn-link" do
        plain "Edit"
      end
    end
  end

  def edit_partial
    matestack_form form_config_helper do
      div class: "mb-3" do
        form_input key: :body, type: :text, placeholder: "What's up?", class: "form-control"
      end
      div class: "mb-3" do
        button 'submit', type: :submit, class: "btn btn-primary", text: "Update!"
      end
    end
  end

  def form_config_helper
    {
      for: context.post, path: post_path(id: context.post.id), method: :put,
      success: {emit: "updated"},
      failure: {emit: "form_failed"},
      errors: {wrapper: {tag: :div, class: 'invalid-feedback'}, input: {class: 'is-invalid'}}
    }
  end

end
```

* [x] Add the update action to the posts controller

`app/controllers/posts_controller.rb`

```ruby
# ...

# PUT /posts/1
def update
  @post = Post.find(params[:id])

  if @post.update(post_params)
    ActionCable.server.broadcast('matestack_ui_core', {
      event: "cable__updated_post",
      data: post_component(post: @post)
    })
    render json: {
      message: 'Post was successfully updated.'
    }, status: :created
  else
    render json: {
      errors: @post.errors,
      message: 'Post could not be updated.'
    }, status: :unprocessable_entity
  end
end

# ...
```

`app/matestack/twitter_clone/posts/index.rb`

```ruby
class TwitterClone::Pages::Posts::Index < Matestack::Ui::Page

  def prepare
    @posts = Post.all
  end

  def response
    post_form_partial
    post_list_partial
  end

  private

  # ...

  def post_list_partial
      # cable prepend_on: "cable__created_post", update_on: "cable__liked_post", id: "post-list" do
      cable prepend_on: "cable__created_post", update_on: "cable__liked_post, cable__updated_post", id: "post-list" do
       @posts.each do |post|
        post_component post: post
      end
    end
  end

end
```

**Test the current state**

* [x] Navigate to `localhost:3000/posts`
* [x] Click on the edit button on a Tweet
* [x] Change the value and submit
* [x] Do it again. And again!
* [x] Party around! You've reached the end of the tutorial!

### Conclusion

We've built a reactive Twitter clone in pure Ruby. Fantastic! :\)

Like it? Consider giving the [project](https://github.com/matestack/matestack-ui-core) a star or even become a [sponsor](https://github.com/sponsors/matestack) on Github, share it with your friends and colleagues \(and family?\) and join our [Discord](https://discord.com/invite/c6tQxFG) server! We're super happy about feedback, looking forward to hear your success stories and help you to build awesome things with Matestack!

