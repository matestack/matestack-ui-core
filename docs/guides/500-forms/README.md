# Forms

Forms are one of the most important components for a lot of applications as they are always needed for user input, like searches, logins, registrations, newsletter subscriptions and much more. Matestack implements a `form` component which could wrap differnt form input components also implemented in matestack like text inputs, number inputs, textareas, selects, checkboxes, radio buttons and more.


## Usage

### Form component

Like in Rails with `form_for` you can create a form in matestack with `form`. It takes a hash as parameter with which you can configure your form and a block with the formular content. In the config hash you can set the HTTP request method, a path, success and failure behavior. You also need to specify a model, string or symbol for what the form is for. All form params will then be submitted nested in this namespace, following Rails behavior and conventions.

```ruby
def response
  form form_config do
    form_input key: :name, label: 'Name'
    # form content goes here
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

Each form requires a few keys for configuration: `:for`, `:path`, `:method`. 

* `:for` can reference an active record object or a string/symbol which will be used to nest params in it. The name of that sorrounds the params is either the given string/symbol or derived from the active record object. In the above case the submitted params will look as follows: `user: { name: 'A name }`.

* `:path` specifies the target path, the form is submitted to 
  
* `:method` sets the request method the form is submitted with

### Form success and failure behavior

Forms will be submitted asynchronously and in case of errors dynamically extended to show errors belonging to inputs fields. In case of a successful request the form is resetted.

**Rendering errors**

If the request failes and the server responds with json containing an `:errors` key and errors following the active record error schema the form automatically renders these errors below the input and adds a css class "error" to the input and "has-errors" to the form. 

Read more about error rendering and customizing form errors at the [form api documentation](/docs/api/100-components/form.md). 

**Customizing success and failure behavior**

We can customize the success and failure behavior of an `form` component by specifiyng the `:success` or `:failure` key with a hash as value. The value hash can contain different keys for different behavior. 

* use `:emit` inside it to emit an event for success or failed responses. 
* use `:transition` to transition to another page. Either specifiyng a hash containing a path and optional params or a hash with `follow_response: true` in order to follow the redirect of the response.
* use `:redirect` with a hash containing a path and params or `follow_response: true` to redirect the browser to the target. Be aware that this will trigger a full website reload as it is a redirect and no transition.

You can also combine `:emit` and one of `:transition`, `:redirect` if wanted.

Read more about success and failure behavior customization at the [form api documentation](/docs/api/100-components/form.md). 

### Input components

Inside a form you can use our form input components `form_input`, `form_textarea`, `form_select`, `form_radio` and `form_checkbox`. Do not use the basic input components `input`, `textarea` and so on, because they do not work with matestack forms. Instead use the _form input_ components. Each input component requires a `:key` which represents the params name as which this inputs value get's submitted. If you specified an active record object or similar in the `form` with the `:for` options, inputs will be prefilled with the value of the corresponding attribute or method of the object. It is also possible to specify `:label` in order to create labels for the input on the fly. 

* `form_input` - Represents a html "input". All w3c specified input types are supported by this component, just pass in your wanted type with the `:type` option. 
  ```ruby
    form_input key: :name, type: :text, label: 'Name'
    form_input key: :age, type: :number, label: 'Age'
    form_input key: :password, type: :password, label: 'Password'
  ```

* `form_textarea` - Represents a html "textarea".
  ```ruby
    form_textarea key: :description, label: 'Description'
  ```

* `form_select` - Represents a html "select". You can pass in values as array or hash under the `:options` key, which then will be rendered as html "option"s. Given an array, value and label will be the same, in case of a hash the key will be used as label and the value as value. In order to allow multiple selections set `multiple: true`. Selected values will then be submitted in an array.
  
* `form_checkbox` - Represents a html "input type=checkbox". You can pass in values as array or hash under the `:options` key, which then will be rendered as checkboxes. Given an array, value and label will be the same, in case of a hash the key will be used as label and the value as value. Selected values will then be submitted in an array. If you leave out `:options` a simple single checkbox will be rendered and a hidden input like rails does which allows for a "true" or "false" checkbox.

* `form_radio` - Represents a html "input type=radio". You can pass in values as array or hash under the `:options` key, which then will be rendered as radio buttons. Given an array, value and label will be the same, in case of a hash the key will be used as label and the value as value.

To learn more about the details of each input component take a look at the [form components api](/docs/api/100-components/form.md)

### Submitting forms

Wrap a button or any markup which should submit the form when clicked in `form_submit`.

----

If you want to know all details about the `form` component and all inputs and their usage as well as how you can customize errors, input placeholder, input value initialization and more checkout it's [api documentation](/docs/api/100-components/form.md).