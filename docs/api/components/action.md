# Matestack Core Component: Action

The action component allows us to trigger async HTTP requests without Javascript!

## Parameters

The core action component accepts the following parameters:

### Method

This specifies which kind of HTTP method should get triggered. It accepts a symbol like so:

```ruby
method: :post
```

### Path

This parameter accepts a classic Rails path, usually in the form of a symbol like so:

```ruby
path: :action_test_path
```

### Params

Using the standard Rails params, we can pass information to our route!

### Data

Here, we can pass data with our request, e.g. in the form of a hash:

```ruby
data: {
  foo: 'bar'
}
```

### Confirm

When specified, a [browser-native confirm dialog](https://developer.mozilla.org/en-US/docs/Web/API/Window/confirm) is shown before the action is actually performed. The action only is performed after the user confirms. The action is not performed if the user declines to confirm dialog.

```ruby
confirm: {
  text: "Do you really want to delete this item?"
}
```

If no `text` is given, the default text "Are you sure?" will be used.

```ruby
confirm: true
```

### Emit

This event gets emitted right after triggering the action. In contrast to the `sucsess` or `failure` events, it will be emitted regardless of the server response.

```ruby
emit: "action_submitted"
```

### Delay

You can use this attribute if you want to delay the actual action submit request. It will not delay the event specified with the `emit` attribute.

```ruby
delay: 1000 # means 1000 ms
```

### Success

The success part of the action component gets triggered once the action we wanted to perform returns a success code, usually the `200` HTTP status code.

To trigger further behavior, we can configure the success part of an action to emit a message like so:

```ruby
success: {
  emit: 'my_action_success'
}
```

#### Perform transition

We can also perform a transition that only gets triggered on success and also accepts further params:

```ruby
success: {
  emit: 'my_action_success',
  transition: {
    path: :action_test_page2_path,
    params: { id: 42 }
  }
}
```

When the server redirects to a url, for example after creating a new record, the transition needs to be configured to follow this redirect of the server response.

```ruby
success: {
  emit: 'my_action_success',
  transition: {
    follow_response: true
  }
}
```

A controller action that would create a record and then respond with the url the page should transition to, could look like this:

```ruby
class TestModelsController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def create
    @test_model = TestModel.create(test_model_params)

    render json: {
      transition_to: test_model_path(@test_model)
    }, status: :ok
  end
end
```

#### Perform redirect

We can also perform a redirect (full page load) that only gets triggered on success and also accepts further params:

Please be aware, that emiting a event doen't have an effect when performing a redirect instead of a transition, as the whole page (including the surrounding app) gets reloaded!

```ruby
success: {
  emit: 'my_action_success', # doesn't have an effect when using redirect
  redirect: {
    path: :action_test_page2_path,
    params: { id: 42 }
  }
}
```

When the server redirects to a url, for example after creating a new record, the redirect needs to be configured to follow this redirect of the server response.

```ruby
success: {
  emit: 'my_action_success', # doesn't have an effect when using redirect
  redirect: {
    follow_response: true
  }
}
```

A controller action that would create a record and then respond with the url the page should redirect to, could look like this:

```ruby
class TestModelsController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def create
    @test_model = TestModel.create(test_model_params)

    render json: {
      redirect_to: test_model_path(@test_model)
    }, status: :ok
  end
end
```

Same applies for the `failure` configuration.


### Failure

As counterpart to the success part of the action component, there is also the possibility to define the failure behavior. This is what gets triggered after the response to our action returns a failure code, usually in the range of `400` or `500` HTTP status codes.

To trigger further behavior, we can configure the failure part of an action to emit a message like so:

```ruby
failure: {
  emit: 'my_action_failure'
}
```

We can also perform a transition that only gets triggered on failure:

```ruby
failure: {
  emit: 'my_action_failure',
  transition: {
    path: :root_path
  }
}
```

### ID (optional)

This parameter accepts a string of ids that the action component should have:

```ruby
id: 'my-action-id'
```

which renders as an HTML `id` attribute, like so:

```html
<a id="my-action-id">...</a>
```

### Class (optional)

This parameter accepts a string of classes that the action component should have:

```ruby
class: 'my-action-class'
```

which renders as an HTML `class` attribute, like so:

```html
<a class="my-action-class">...</a>
```

### Notify

Not in use right now.

## Examples

See some common use cases for the action core component below:

### Example 1 - Async request with payload

First, make sure our routes accept requests the way we want to use them.  Modify them in `config/routes.rb`

```ruby
post '/action_test', to: 'action_test#test', as: 'action_test'
```

After that, you can specify an action on our example page. Notice how we wrap a button to have something visible to click and trigger the action!

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    # our action component wraps a simple button
    action action_config do
      button text: 'Click me!'
    end
  end

  # this is where our action is defined
  def action_config
    return {
      method: :post,
      path: :action_test_path,
      data: {
        foo: 'bar'
      }
    }
  end

end
```

In this case, the `ActionTestController` receives `:foo => 'bar'` in the params.

### Example 2: Async request with URL param

Instead of sending _raw_ data, we can also explicitly pass params to a route. Like in the example above, we open up the route we intend to use in `config/routes.rb`:

```ruby
post '/action_test/:id', to: 'action_test#test', as: 'action_test_with_url_param'
```

And on the example page, we specify our action component's behavior:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    # our action component again wraps a button
    action action_config do
      button text: 'Click me!'
    end
  end

  def action_config
    return {
      method: :post,
      path: :action_test_with_url_param_path,
      params: {
        id: 42
      }
    }
  end

end
```

This example simply sends the param `:id => '42'` to the route we have defined!

### Example 3: Success/Failure Behavior

Now, we examine different cases on how to handle success/failure scenarios.

Again, we look at our routes beforehand. This time, we define two different endpoints in `config/routes.rb`:

```ruby
post '/success_action_test', to: 'action_test#success_test', as: 'success_action_test'
post '/failure_action_test', to: 'action_test#failure_test', as: 'failure_action_test'
```

Let's also take a look at the `app/controllers/action_test_controller.rb` to see what the endpoints do:

```ruby
class ActionTestController < TestController

  def success_test
    render json: { message: 'server says: good job!' }, status: 200
  end

  def failure_test
    render json: { message: 'server says: something went wrong!' }, status: 400
  end

end
```

### Example 3.1: Async request with success event emit used for rerendering

Below, we define an action component and an async component. The async component is documented [here](/docs/components/async.md),
for now it is just important that it waits for our `action_config` success message and will get re-rendered.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    # this is our action component
    action action_config do
      button text: 'Click me!'
    end
    # here, we have an async component gets re-rendered on action success
    async rerender_on: 'my_action_success', id: "my-async-component" do
      div id: 'my-div' do
        plain "#{DateTime.now.strftime('%Q')}"
      end
    end
  end

  def action_config
    return {
      method: :post,
      path: :success_action_test_path,
      success: {
        emit: 'my_action_success'
      }
    }
  end

end
```

Now, if we click the button and everything goes well (which should be the case in this very simple example), we can see the timestamp gets updated - nice!

### Example 3.2: Async request with success event emit used for notification

In this example, we will show a message that gets triggered once the controller returns a status code of `200`:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    # same configuration as before
    action action_config do
      button text: 'Click me!'
    end
    # different async behavior
    toggle show_on: 'my_action_success', hide_after: 300 do
      plain '{{ event.data.message }}'
    end
  end

  def action_config
    return {
      method: :post,
      path: :success_action_test_path,
      success: {
        emit: 'my_action_success'
      }
    }
  end

end  
```

This time, after clicking our action component we should see the `good job!` message that was initially hidden and disappears again after 300ms.

### Example 3.3: Async request with failure event emit used for notification

In the examples before, we always assumed (and made sure) that things went well. Now, it's the first time to use the `failure_action_test_path` to see how we can notify the user if things go wrong!

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    # our good old action including a button
    action action_config do
      button text: 'Click me!'
    end
    # success message, initially hidden and removed after 300ms
    toggle show_on: 'my_action_success', hide_after: 300 do
      plain '{{ event.data.message }}'
    end
    # failure message, initially hidden and removed after 300ms
    toggle show_on: 'my_action_failure', hide_after: 300 do
      plain '{{ event.data.message }}'
    end
  end

  def action_config
    return {
      method: :post,
      # notice that we post to the failure path on purpose to receive a status code of 500
      path: :failure_action_test_path,
      success: {
        emit: 'my_action_success'
      },
      failure: {
        emit: 'my_action_failure'
      }
    }
  end

end
```

Now, clicking the button shows the failure message - just as we expected it to!

### Example 3.4: Async request with success event emit used for transition

Unlike before, we will use the action component to trigger a page transition!

Again, we start by defining our routes in `config/routes.rb`:

```ruby
scope :action_test do
  get 'page1', to: 'example_app_pages#page1', as: 'action_test_page1'
  get 'page2/:id', to: 'example_app_pages#page2', as: 'action_test_page2'
end
```

Our example app layout, already including placeholders for success/failure notifications:

```ruby
class Apps::ExampleApp < Matestack::Ui::App

  def response
    heading size: 1, text: 'My Example App Layout'
    main do
      yield_page
    end
    toggle show_on: 'my_action_success', hide_after: 300 do
      plain '{{ event.data.message }}'
    end
    toggle show_on: 'my_action_failure', hide_after: 300 do
      plain '{{ event.data.message }}'
    end
  end

end
```

To make a transition from one page to the other work, we need to make both of them available in our controller:

```ruby
class ExampleAppPagesController < ExampleController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app ExampleApp

  def page1
    render ExampleApp::Pages::ExamplePage
  end

  def page2
    render ExampleApp::Pages::SecondExamplePage
  end

end
```

The first page, including an action component that performs a page transition to page 2 on success!

```ruby
class ExampleApp::Pages::ExamplePage < Matestack::Ui::Page

  def response
    heading size: 2, text: 'This is Page 1'
    action action_config do
      button text: 'Click me!'
    end
  end

  def action_config
    return {
      method: :post,
      path: :success_action_test_path,
      success: {
        emit: 'my_action_success',
        transition: {
          path: :action_test_page2_path,
          params: { id: 42 }
        }
      }
    }
  end

end
```

The second page, including an action that shows us the failure message we defined in the controller and then transfers us back to page 1.

```ruby
class ExampleApp::Pages::SecondExamplePage < Matestack::Ui::Page

  def response
    heading size: 2, text: 'This is Page 2'
    action action_config do
      button text: 'Click me!'
    end
  end

  def action_config
    return {
      method: :post,
      path: :failure_action_test_path,
      failure: {
        emit: 'my_action_failure',
        transition: {
          path: :action_test_page1_path
        }
      }
    }
  end

end
```

Now, we can visit `localhost:3000/action_test/page1` and see our first page, shown by the `This is Page 1` text.

There, we can click on our button (`Click me!`) and get transfered to the second page. There, we see the `This is Page 2` text and, for 300ms, our `server says: good job!` success message. Neat!

If we click the button (`Click me!`) on the second page, we get the failure message (`server says: something went wrong!`) and get sent back to page 2, just as we wanted to.
