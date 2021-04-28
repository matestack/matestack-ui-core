# Overview

The `action` component can be used to trigger asynchronous requests from for example a button click or any other html markup. The `action` components let's us wrap content in an `a` tag which is then clickable and triggers a background request with the configured request method to the configured path and with optionally given params and let's us react to the server response. It can distinguish between a successful and failed response and emit events, transition somewhere, completely redirect and more. You only need to configure it according to your needs.

Let's assume we want a delete button on a products show page in an admin app. Deleting a product would require us to send a DELETE request to the `product_path(product)`. In the example below, clicking the "Delete" button will trigger an asynchronous DELETE request to the `products_path(id)` with params `foo: :bar`. If successful the action component will trigger a transition to the path the controller redirected us to. If the request failed it will emit the "deletion-failed" event.

We recommend defining the expected hash parameter for `action` components in a method for better readability.

```ruby
def response
  action action_config do
    button 'Delete'
  end
end

def action_config
  {
    path: product_path(product),
    method: :delete,
    params: {
      foo: :bar
    },
    sucess: {
      transition: {
        follow_response: true
      }
    },
    failure: {
      emit: 'deletion-failed'
    }
  }
end
```

**Basic confirm dialog**

By adding `confirm: true` inside the config, the `action` component will show a [browser-native confirm dialog](https://developer.mozilla.org/en-US/docs/Web/API/Window/confirm) before performing the request. When specified, a [browser-native confirm dialog](https://developer.mozilla.org/en-US/docs/Web/API/Window/confirm) is shown before the action is actually performed. The action only is performed after the user confirms. The action is not performed if the user declines to confirm dialog.

**Success and failure behavior**

We can customize the success and failure behavior of an `action` component by specifiyng the `:success` or `:failure` key with a hash as value. The value hash can contain different keys for different behavior.

* use `:emit` inside it to emit an event for success or failed responses. 
* use `:transition` to transition to another page. Either specifiyng a hash containing a path and optional params or a hash with `follow_response: true` in order to follow the redirect of the response.
* use `:redirect` with a hash containing a path and params or `follow_response: true` to redirect the browser to the target. Be aware that this will trigger a full website reload as it is a redirect and no transition.

You can also combine `:emit` and one of `:transition`, `:redirect` if wanted.

{% page-ref page="action-component-api.md" %}

