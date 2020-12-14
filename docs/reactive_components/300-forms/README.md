# Forms

Matestack implements a `form` component which wraps different child form input components like text inputs, number inputs, textareas, selects, checkboxes, radio buttons and more in order to collect user input. The `form` component is implemented with Vue.js and is designed to submit its data via an async HTTP request, usually targeting a Rails controller action through Rails routing, when submitted. The `form` can reset itself, render serverside errors, emit events and perform transitions without full browser page reload after form submission. Alternatively, the form can perform a redirect resulting in a full browser page reload after submission.

## Usage

### Basic configuration

Like Rails' `form_for`, Matestack's `form` takes a hash as parameter which is used to configure the form. Within the block of a `form`, child components like `form_input` are used to collect user input:

```ruby
def response
  form form_config do
    form_input key: :name, type: :text, label: 'Name'
    # ...
    form_submit do
      button text: "submit", type: :submit
    end
  end
end

# we use a helper method to define the config hash
def form_config
  {
    for: User.new
    path: users_path,
    method: :post
  }
end
```

Each form requires a few keys for configuration: `:for`, `:path`, `:method`.

* `:for` can reference an active record object or a string/symbol which will be used to nest params in it. The name of that surrounds the params is either the given string/symbol or derived from the active record object. In the above case the submitted params will look as follows: `user: { name: 'A name }`.

* `:path` specifies the target path, the form is submitted to (can be a plain String or a Rails url helper method)

* `:method` sets the HTTP method the form is using to submit its data, can be `:post` or `:put`

### Serverside action

As mentioned, the `form` posts its data to a specified Rails controller action through Rails routing.

**Be aware to change the response structure of scaffolded Rails controller action like seen below in order to support a Matestack form:**

`app/controllers/users_controller.rb`

```ruby
class UsersController < ApplicationController

  # ...

  def create
    @user = User.new(user_params)

    # instead of:

    # respond_to do |format|
    #   if @user.save
    #     format.html { redirect_to @user, notice: 'User was successfully created.' }
    #     format.json { render :show, status: :created, location: @user }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @user.errors, status: :unprocessable_entity }
    #   end
    # end

    # do this:

    if @user.save
      render json: {
        message: 'User was successfully created.'
      }, status: :created
    else
      render json: {
        errors: @user.errors,
        message: 'User could not be created.'
      }, status: :unprocessable_entity
    end
  end

  # ...

  private

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name)
    end

end
```

### Form success and failure behavior

Forms will be submitted asynchronously and in case of errors dynamically extended to show errors belonging to inputs fields. In case of a successful request the form is resetted, unless configured not to do so.

**Rendering errors**

If the request fails and the server responds with JSON containing an `:errors` key and errors following the ActiveRecord error schema, the form automatically renders these errors below the inputs and adds a css class `error` to the each input with an error and `has-errors` to the wrapping form tag:

```html
<form class="matestack-form has-errors">
  <input type="text" class="error">
  <span class="errors">
    <!-- for each error string within the error array for the key 'title' -->
    <span class="error">
      can't be blank
    </span>
  </span>
</form>
```

In order to change the DOM structure and applied CSS classes for errors, you can adjust the error rendering via configuration. The code below for example is meant to support Bootstrap form error classes:

```ruby
def form_config
  {
    for: User.new
    path: users_path,
    method: :post,
    errors: {
      wrapper: { tag: :div, class: 'invalid-feedback' },
      input: { class: 'is-invalid' }
    }
  }
end
```

Read more about error rendering and customizing form errors at the [form api documentation](/docs/api/100-components/form.md).

**Customizing success and failure behavior**

We can customize the success and failure behavior of a `form` component by specifiyng the `:success` or `:failure` key with a hash as value. The value hash can contain different keys for different behavior.

* use `:emit` inside it to emit an event for success or failed responses.
* use `:transition` to transition to another page. Either specifiyng a hash containing a path and optional params or a hash with `follow_response: true` in order to follow the redirect of the response.
* use `:redirect` with a hash containing a path and params or `follow_response: true` to redirect the browser to the target. Be aware that this will trigger a full website reload as it is a redirect and no transition.

You can also combine `:emit` and one of `:transition`, `:redirect` if wanted.

If you want to show a separate success or error message after form submission, you can use the emitted events in order to trigger `toggle` components to show up for a 5 seconds:

```ruby
def response
  form form_config do
    form_input key: :name, type: :text, label: 'Name'
    # ...
    form_submit do
      button text: "submit", type: :submit
    end
  end
  toggle show_on: "submitted", hide_after: 5000 do
    span class: "some-success-styling", text: "Yeah! It worked!"
  end
  toggle show_on: "failed", hide_after: 5000 do
    span class: "some-error-styling", text: "Damn! Somenthing went wrong!"
  end
end

def form_config
  {
    for: User.new
    path: users_path,
    method: :post,
    success: {
      emit: "submitted"
    },
    failure: {
      emit: "failed"
    }
  }
end
```

This will render static texts "Yeah! It worked!" or "Damn! Somenthing went wrong!" in a `span` after form submission. If you want to render the serverside message defined with `render json: {
  message: 'User was successfully created.'
}, status: :created`, you would have to add some minor Vue.js to the `toggle` content:

```ruby
# ...
toggle show_on: "submitted", hide_after: 5000 do
  span class: "some-success-styling", text: "Yeah! {{ event.data.message }}"
end
toggle show_on: "failed", hide_after: 5000 do
  span class: "some-error-styling", text: "Damn! {{ event.data.message }}"
end
# ...
```

Now the serveside messages will appear within the `toggle` components.

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


## Complete documentation

If you want to know all details about the `form` component and all inputs and their usage as well as how you can customize errors, input placeholder, input value initialization and more checkout it's [api documentation](/docs/api/100-components/form.md).
