# Reactivity in pure Ruby

In addition to Matestack's core components, rendering HTML tags like `div` and `span`, Matestack offers Vue.js driven core components enabling you to implement reactive UIs just using a simple Ruby DSL.

A reactive component renders a HTML component tag with some special attributes and props around the response defined in the Ruby component. The corresponding Vue.js JavaScript component, defined in a separate, pure JavaScript file will treat the response of the Ruby component as its template. This is how the reactive core components are built. But you can create your own Vue.js driven components as well!

Under the hood, Matestack's reactive core components use a Vue.js event hub and a Vuex Store in order to control clientside dataflow. Your own reactive components may use them as well!

## Overview of reactive core components

**onclick**

The `onclick` component is very simple. It can emit an event if the contents of the `onclick` component gets clicked. This component shows its potential when used with other components that can react to events like `toggle`, `async`, `isolated`.

```ruby
onclick emit: 'my-event' do
  button text: 'Click me!'
end
```

Read more about the [onclick component](/docs/api/100-components/onclick.md).

**toggle**

The `toggle` component can toggle its view state according to either events or timers. It can show or hide its content after one of the specified events is received or hide its content after a certain amount of time. You can use it for example to show a notification if a special event occurs and automatically hide the notification after a certain period.  

```ruby
# showing content after 'my-event' was received and hiding it after 2s
toggle show_on: 'my-event', hide_after: 2000 do
  paragraph text: 'Your notification content'
end
```

Read more about the [toggle component](/docs/api/100-components/toggle.md).

**action**

The `action` component can be used to trigger a asynchronous request from for example a button click. Let's assume we want a delete button on our products show page in the management app. Deleting a product would require us to send a DELETE request to the `product_path(product.id)`. The `action` components let's us wrap content which is then clickable and triggers a request with the configured request method to the configured path and with the given params (giving you the ability to add whatever params you want) and let's us react to the server response. It can distinguish between a successful and failed response and emit events, transition somewhere, completely redirect and more for both. You only need to configure it according to your needs.

```ruby
def response
  action action_config do
    button text: 'Delete'
  end
end

def action_config
  {
    path: product_path(product.id),
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

In the example above, clicking the "Delete" button will trigger an asynchronous DELETE request to the `products_path(id)` with params `foo: :bar`. If successful the action component will trigger a transition to the path the controller redirected us to. If it failed we will emit the "deletion-failed" event.

We recommend defining the expected hash parameter for `action` components in a method, because they can get quite large.

Read more about the [action component](/docs/reactive_components/200-actions/README.md).

**forms**

Like in Rails with `form_for` you can create a form in matestack with `form`. It takes a hash as parameter with which you can configure your form. In the config hash you can set the HTTP request method, a path, success and failure behavior. You also need to specify a model, string or symbol for what the form is for. All form params will then be submitted nested in this namespace, following Rails behavior and conventions.

```ruby
def response
  form form_config do
    form_input key: :name, type: :text, label: 'Name'
    form_input key: :age, type: :number, label: 'Name'
    textarea key: :description, label: 'Description'
    form_select key: :experience, options: ['Junior', 'Senior']
    form_radio key: :newsletter, options: { 'Yeah, a newsletter.': 1, 'Oh no. Not again.': 0 }, label: 'Name'
    form_checkbox key: :conditions, label: "I've read the terms and conditions"
    form_submit do
      button text: 'Save'
    end
  end
end

def form_config
  {
    for: User.new
    path: users_path,
    method: :post,
    success: {
      transition: {
        follow_redirect: true
      }
    },
    failure: {
      emit: 'user_form_failure'
    }
  }
end
```

Inside a form you can use our form input components `form_input`, `form_textarea`, `form_select`, `form_radio` and `form_checkbox`. Each input component requires a `:key` which represents the params name as which this inputs value get's submitted. It is also possible to specify `:label` in order to create labels for the input on the fly. Some form components can take additional `:options` as a array or hash, which will render a the passed options. For inputs with possible multiple values, like checkboxes or multisecelects, the selected values are submitted in an array, following again Rails behavior. To learn more about the details of each input component take a look at the [form components api](/docs/api/100-components/form.md)

Wrap a button or any markup which should submit the form when clicked in `form_submit`.

Each form requires a few keys for configuration: `:for`, `:path`, `:method`. Like said above, `:for` can reference a active record object or a string/symbol which will be used to nest params in it. `:path` specifies the target path, the form is submitted to with the configured request method in `:method`.

Forms will be submitted asynchronously and in case of errors dynamically extended to show errors belonging to inputs fields, but it is possible to set custom form behavior in success or failure cases. You could transition to another page, follow the redirect from the server as a transition or normal redirect, or emit events to leverage the above mentioned event hub.

To learn more, check out the [form guide](/docs/reactive_components/300-forms/README.md).

**async**

The `async` component can be used to load or reload content asynchronously depending on page initialization or events. Simply wrap your content which you want to render asynchronously inside the `async` component. In order to load the content asynchronously after the initial page load use `defer: true` or pass in a number to delay the defer. To reload content you can use `:rerender_on` with an event name, leveraging the event hub, to reload the content if the specified event occurs. For example rerendering a list of todos beneath the form to create todos to instantly show new created objects. Remember events can also be used with action cable, which you could use for "real time" synchronization.

```ruby
def response
  paragraph text: 'Time when you pressed the button'
  async id: 'current-time', rerender_on: 'update-time' do
    paragraph text: Time.now
  end
  onclick emit: 'update-time' do
    button text: 'Update Time'
  end
end
```

The above code snippet renders initially a paragraph and the current time followed by a button which emits the "update-time" event. The `async` component triggers an asynchronous request when the event is recieved, requesting it's content from the server. The server will respond with only the contents of the `async` components which is then replaced.

Read more about the [action component](/docs/reactive_components/400-async/README.md).

**isolated**

Isolated components work similar to `async` components, but there are a few differences. Isolated components can not be called or used with a block like async, instead you need to create a custom component inheriting from `Matestack::Ui::IsolatedComponent`. Creation of the custom component works similar to other components, except you need to implement an `authorized?` method. This is needed because isolated components are resolved independently, they are not calling your app, page or anything else like `async` does. Therefore they need to resolve all data independently, but can access params to do so.

So isolated components are resolved completely indepentendly unlike async for which the whole page is executed but only the async block is rendered.

You can of course use every matestack component inside an isolated component, even `async` or another isolated component.

Read more about the [isolated component](/docs/reactive_components/600-isolated/README.md).

**collection**

With the `collection` component you can display active record model or similar collections and add features like filtering, paginating and ordering with ease. Each of these features requires no page reload to take effect, because the `collection` component leverages a `async` component in combination with the event hub to only reload the effected content of the collection. The `collection` component is a bit more complex as it offers a lot of functionality, that's why we will not explain the rudimentary usage here.

Take a look at the [collection component guide](/docs/reactive_components/700-collection/README.md) to learn how it works and how to use it.
