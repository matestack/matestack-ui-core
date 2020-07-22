# matestack core component: Form

Show [specs](/spec/usage/components/form_spec.rb)

The `form` core component is a vue.js driven dynamic component. It enables you to implement dynamic forms without writing javascript. It relies on child components to collect and submit user input: `form_input`, `form_select`, `form_submit` and `form_textarea`. They are described within this documentation page.

## Parameters

The core form component accepts the following parameters. Pass them in as a hash like so:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form some_form_config, :include do
        #...
      end
    }
  end

  def some_form_config
    {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      #...
    }
  end

end
```

Don't forget to add the special keyword `:include`! This enables the form_* child components to access the configuration of ther parent `form` component.

### For

The `form` component wraps the input in an object. The name of this object can be set in multiple ways:

#### set as a symbol

```ruby
for: :my_object
```

```ruby
form some_form_config, :include do
  form_input key: :some_input_key, type: :text
end
```

When submitting this form, the `form` component will perform a request with a payload like this:

```ruby
my_object: {
  some_input_key: "foo"
}
```

#### set by Active Record class name

```ruby
@my_model = MyActiveRecordModel.new
#...
for: @my_model
```

```ruby
form some_form_config, :include do
  form_input key: :some_model_attribute, type: :text
end
```

When submitting this form, the `form` component will perform a request with a payload like this:

```ruby
my_active_record_model: {
  some_model_attribute: "foo"
}
```

Please be aware that if you use an Active Record model, the keys of the input components should match a model attribute/method. The form automatically tries to prefill the form inputs through calling the keys as methods on the model.

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

```ruby
params: { id: 42 }
```

### Emit

This event gets emitted right after form submit. In contrast to the `sucsess` or `failure` events, it will be emitted regardless of the server response.

```ruby
emit: "form_submitted"
```

### Delay

You can use this attribute if you want to delay the actual form submit request. It will not delay the event specified with the `emit` attribute.

```ruby
delay: 1000 # means 1000 ms
```

### Multipart

If you want to perform file uploads within this form, you have to set `multipart` to true. It will send the form data with `"Content-Type": "multipart/form-data"`

```ruby
multipart: true # default is false which results in form submission via "Content-Type": "application/json"
```

### Success

The success part of the `form` component gets triggered once the controller action we wanted to call returns a success code, usually the `2xx` HTTP status code.


#### Emit event

To trigger further behavior, we can configure the success part of a `form` to emit a message like so:

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

Same applies for the `failure` configuration.

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

#### Reset form

If submitted successfully, the `form` component resets its state by default when using the "post" method. When using the "put" method, the state is not resetted by default. You may control this behavior explictly by using the `reset` option:

```ruby
method: :post
success: {
  emit: 'my_action_success',
  reset: false #default true when using the :post method when submitted successfully
}
```

```ruby
method: :put
success: {
  emit: 'my_action_success',
  reset: true #default false when using the :put method when submitted successfully
}
```


### Failure

As counterpart to the success part of the `form` component, there is also the possibility to define the failure behavior. This is what gets triggered after the response to our `form` submit returns a failure code, usually in the range of `400` or `500` HTTP status codes.

#### Emit event

To trigger further behavior, we can configure the failure part of an action to emit a message like so:

```ruby
failure: {
  emit: 'my_action_failure'
}
```


#### Perform transition

We can also perform a transition that only gets triggered on failure:

```ruby
failure: {
  emit: 'my_action_failure',
  transition: {
    path: :root_path
  }
}
```

#### Reset form

The `form` component does not reset its state by default when not submitted successfully. You may control this behavior explictly by using the `reset` option:

```ruby
method: :post
failure: {
  emit: 'my_action_failure',
  reset: true #default false when using the :post method and not successful
}
```

```ruby
method: :put
failure: {
  emit: 'my_action_failure',
  reset: true #default false when using the :put method and not successful
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


## Examples

These examples show generic use cases and can be used as a guideline of what is possible with the form core component.

Beforehand, we define some example routes for the form input in our `config/routes.rb`:

```ruby
post '/success_form_test/:id', to: 'form_test#success_submit', as: 'success_form_test'
post '/failure_form_test/:id', to: 'form_test#failure_submit', as: 'failure_form_test'
post '/model_form_test', to: 'model_form_test#model_submit', as: 'model_form_test'
```

We also configure our example controllers to accept form input and react in a predictable and verbose way:

```ruby
class FormTestController < ApplicationController

  def success_submit
    render json: { message: 'server says: form submitted successfully' }, status: 200
  end

  def failure_submit
    render json: {
      message: 'server says: form had errors',
      errors: { foo: ['seems to be invalid'] }
    }, status: 400
  end

end
```

```ruby
class ModelFormTestController < ApplicationController

  def model_submit
    @test_model = TestModel.create(model_params)
    if @test_model.errors.any?
      render json: {
        message: 'server says: something went wrong!',
        errors: @test_model.errors
      }, status: :unprocessable_entity
    else
      render json: {
        message: 'server says: form submitted successfully!'
      }, status: :ok
    end
  end

  protected

  def model_params
    params.require(:test_model).permit(:title, :description, :status, some_data: [], more_data: [])
  end

end
```

### Example 1: Async submit request with clientside payload

On our example page, we define a form that accepts text input and has a submit button.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'my-test-input', key: :foo, type: :text
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

When we visit `localhost:3000/example`, fill in the input field with *bar* and click the submit button, our `FormTestController` receives the input.

Furthermore, our *bar* input disappears from the input field - Easy!

### Example 2: Async submit request with failure event

This time, we break the form input on purpose to test our failure message! Again, we define our example page. Notice that we explicitly aim for our `failure_form_test_path`.

```ruby
class ExamplePage < Matestack::Ui::Page

def response
  components {
    form form_config, :include do
      form_input id: 'my-test-input', key: :foo, type: :text
      form_submit do
        button text: 'Submit me!'
      end
    end
    async show_on: 'my_form_failure' do
      plain "{{event.data.message}}"
      plain "{{event.data.errors}}"
    end
  }
end

def form_config
  return {
    for: :my_object,
    method: :post,
    path: :failure_form_test_path,
    params: {
      id: 42
    },
    failure: {
      emit: 'my_form_failure'
    }
  }
end

end
```

Now, when we visit our example page on `localhost:3000/example` and fill in the input field with e.g. *bar* and hit the submit button, we get displayed both `server says: form had errors` and `'foo': [ 'seems to be invalid' ]`. Just what we expected to receive!

### Example 3: Async submit request with success transition

In this example, things get a bit more complex. We now want to transition to another page of our application after successfully submitting a form!

In order to additionally show a success/failure message, we define our matestack app layout with messages, using the *async core component*:

```ruby
class Apps::ExampleApp < Matestack::Ui::App

  def response
    components {
      heading size: 1, text: 'My Example App Layout'
      main do
        page_content
      end
      async show_on: 'my_form_success', hide_after: 300 do
        plain "{{event.data.message}}"
      end
      async show_on: 'my_form_failure', hide_after: 300 do
        plain "{{event.data.message}}"
        plain "{{event.data.errors}}"
      end
    }
  end

end
```

On our first example page, we define our form to transfer us to the second page (`form_test_page_2_path`) on successful input:

```ruby
class Pages::ExampleApp::ExamplePage < Matestack::Ui::Page

  def response
    components {
      heading size: 2, text: 'This is Page 1'
      form form_config, :include do
        form_input id: 'my-test-input-on-page-1', key: :foo, type: :text
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      },
      success: {
        emit: 'my_form_success',
        transition: {
          path: :form_test_page_2_path,
          params: {
            id: 42
          }
        }
      }
    }
  end

end
```

On the second example page, we aim for our failure path (`failure_form_test_path`) on purpose and define our form to transfer us to the first page (`form_test_page_1_path`) on failed input:

```ruby
class Pages::ExampleApp::SecondExamplePage < Matestack::Ui::Page

  def response
    components {
      heading size: 2, text: 'This is Page 2'
      form form_config, :include do
        form_input id: 'my-test-input-on-page-2', key: :foo, type: :text
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :failure_form_test_path,
      params: {
        id: 42
      },
      failure: {
        emit: 'my_form_failure',
        transition: {
          path: :form_test_page_1_path
        }
      }
    }
  end

end
```

Of course, to reach our two newly defined pages, we need to make them accessible through a controller:

```ruby
class ExampleAppPagesController < ExampleController
  include Matestack::Ui::Core::ApplicationHelper

  def page1
    responder_for(Pages::ExampleApp::ExamplePage)
  end

  def page2
    responder_for(Pages::ExampleApp::SecondExamplePage)
  end

end
```

We also need to extend our routes in `config/routes.rb` to handle the new routes:

```ruby
scope :form_test do
  get 'page1', to: 'example_app_pages#page1', as: 'form_test_page_1'
  get 'page2/:id', to: 'example_app_pages#page2', as: 'form_test_page_2'
end
```

Now, if we visit `localhost:form_test/page1`, we can fill in the input field with e.g. *bar* and click the submit button.

We then get displayed our nice success message (`server says: form submitted successfully`) and get transferred to our second page.

If we fill in the the input field there and hit the submit button, we not only see the failure messages (`server says: form had errors` and `'foo': [ 'seems to be invalid' ]`), we also get transferred back to the first page, just the way we specified this behavior in the page definition above!

### Example 3.1: Async submit request with success transition - dynamically determined by server

In the example shown above, the `success` `transition` is statically defined. Sometimes the `transition` needs to be dynamically controlled within the server action.
Imagine creating a new Active Record instance with a `form`. If you want to show the fresh instance on another page and therefore want to define a `transition` after successful form submission, you would need to know the ID of the fresh instance! That is not possible, as the ID is auto-generated and depends on the current environment/state. Therefore you can tell the `form` component to follow a transition, which the server action defines after creating the new instance (and now knowing the ID):

On the `page`:
```ruby
#...

def form_config
  return {
    for: :my_object,
    method: :post,
    path: :success_form_test_path,
    success: {
      emit: 'my_form_success',
      transition: {
        follow_response: true # follow the serverside transition
      }
    }
  }
end
```
On the `controller` `action`:

```ruby
#...
def model_submit
  @test_model = TestModel.create(model_params)
  if @test_model.errors.any?
    render json: {
      message: 'server says: something went wrong!',
      errors: @test_model.errors
    }, status: :unprocessable_entity
  else
    render json: {
      message: 'server says: form submitted successfully!',
      transition_to: some_other_path(id: @test_model.id) #tell the form component where to transition to with the id, which was not available before
    }, status: :ok
  end
end
```

### Example 4: Multiple input fields of different types

Of course, our input core component accepts not only 'text', but very different input types: In this example, we will introduce 'password', 'number', 'email', 'range', 'textarea' types!

On our example page, we define the input fields, together with a `type: X` configuration:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'text-input',      key: :text_input, type: :text
        form_input id: 'email-input',     key: :email_input, type: :email
        form_input id: 'password-input',  key: :password_input, type: :password
        form_input id: 'number-input',    key: :number_input, type: :number
        form_input id: 'range-input',     key: :range_input, type: :range
        form_input id: 'textarea-input',  key: :textarea_input, type: :textarea
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, we can visit `localhost:3000/example` and fill in the input fields with various data that then gets sent to the corresponding path, in our case `success_form_test_path`.

### Example 5: Initialization with a value

Our form_input field doesn't need to be empty when we load the page. We can `init` it with all kinds of values:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'text-input', key: :text_input, type: :text, init: 'some value'
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, when we visit `localhost:3000/example`, we see our input field already welcomes us with the value *some value*!

### Example 6: Pre-filling the input field with a placeholder

Instead of a predefined value, we can also just show a placeholder in our form_input component:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'text-input', key: :text_input, type: :text, placeholder: 'some placeholder'
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, when we visit `localhost:3000/example`, the input field is technically empty, but we see the text *some placeholder*. In contrary to the `init` value in example 5, the placeholder can't get submitted)!

### Example 7: Defining a label

Another useful feature is that we can also give a *label* to our form_input!

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'text-input', key: :text_input, type: :text, label: 'some label'
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, when we visit `localhost:3000/example`, the input field carries a *some label*-label.

### Example 8: Asynchronously display error messages

Here, we aim for the `failure_form_test_path` on purpose to check how error messages are handled!

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_input id: 'text-input', key: :foo, type: :text
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :failure_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

If we head to `localhost:3000/example`, and fill in the input field with, e.g., *text* and click the submit button, we will get displayed our error message of `seems to be invalid`. Neat!

### Example 9: Mapping the form to an Active Record Model

To test the mapping of our form to an Active Record Model, we make sure our `TestModel`'s description can't be empty:

```ruby
class TestModel < ApplicationRecord

  validates :description, presence:true

end
```

Now, on our example page, we _prepare_ a new instance of our `TestModel` that we then want to save through the form component:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.title = 'Title'
  end

  def response
    components {
      form form_config, :include do
        form_input id: 'title', key: :title, type: :text
        form_input id: 'description', key: :description, type: :text
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Notice that we only _prepared_ the title, but missed out on the description.

If we head to our example page on `localhost:3000/example`, we can already see the title input field filled in with *Title*. Trying to submit the form right away gives us the error message (`can't be blank`) because the description is, of course, still missing!

After filling in the description with some input and hitting the submit button again, the instance of our `TestModel` gets successfully saved in the database - just the way we want it to work.

### Example 10: Form select components

Instead of typing in text, we can also offer select fields to our users. Right now, we have three of them in our core library:

#### Example 10.1: The Dropdown

For the dropdown select component, there are also some different possibilities:

##### Example 10.1.1: Use an array of options or a hash

On our example page, inside our form component we define two `form_select` fields, both with `type: dropdown`. One takes an array, the other takes a hash as `optins` to select from.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-dropdown', key: :array_input, type: :dropdown, options: ['Array Option 1','Array Option 2']
        form_select id: 'my-hash-test-dropdown', key: :hash_input, type: :dropdown, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, we can visit our example page on `localhost:3000/example` and choose one value from both of our dropdown menues. After clicking the submit button, both of them get sent to the route we defined in the `form_config`, in this case `success_form_test_path`.

##### Example 10.1.2: Initializing a dropdown with a value

In addition to the example above, we now `init` our form_select dropdown fields with specific values from our `options`. Notice that this works with both arrays and hashes!

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-dropdown', key: :array_input, type: :dropdown, options: ['Array Option 1','Array Option 2'], init: 'Array Option 1'
        form_select id: 'my-hash-test-dropdown', key: :hash_input, type: :dropdown, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }, init: '1'
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

On our example page on `localhost:3000/example`, we can now see that both dropdown fields already have a pre-chosen value that we can (but not necessarily have to) submit right away.


##### Example 10.1.3: Mapping it to an Active Record Model Array Enum

Let's use our dropdown form_select field on our `TestModel`'s status via an enum array. We first define it in our `models/test_model.rb`:

```ruby
class TestModel < ApplicationRecord

  enum status: [ :active, :archived ]

end
```

When defining our example page, we again _prepare_ a new instance of the `TestModel` and this time set a `status` there. This `status` is then used in the `form_select` field, using the `type: dropdown` configuration:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.status = 'active'
  end

  def response
    components {
      form form_config, :include do
        form_input id: 'description', key: :description, type: :text
        form_select id: 'status', key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Visiting the example page, we see the status of our `TestModel` pre-filled as `active`, and the description being empty. We can simply type in a description and choose whether we want to change the `status` via our dropdown form_select field. Anyway, our model will get updated in the database on clicking the submit button!


##### Example 10.1.4: Mapping it to an Active Record Model Hash Enum

Very similiar to the example above, but this time we define our `TestModel`'s status as a hash:

```ruby
class TestModel < ApplicationRecord

  enum status: { active: 0, archived: 1 }

end
```

When defining our example page, we again _prepare_ a new instance of the `TestModel` and this time set a `status` there. This `status` is then used in the `form_select` field, using the `type: dropdown` configuration:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.status = 'active'
  end

  def response
    components {
      form form_config, :include do
        form_input id: 'description', key: :description, type: :text
        form_select id: 'status', key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

The behavior is just the same as in Example 10.1.4!

##### Example 10.1.5: Mapping it to Active Record Model Errors

Now, we want to provoke a validation error in our form! Therefor, we modify our example above by making the status a required attribute for our `TestModel`:

```ruby
class TestModel < ApplicationRecord

  enum status: { active: 0, archived: 1 }

  validates :status, presence: true

end
```

On our example page, we _prepare_ our `TestModel` instance, but leave the status blank on purpose:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
  end

  def response
    components {
      form form_config, :include do
        form_select id: 'status', key: :status, type: :dropdown, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Visiting our example page and trying to submit the form without selecting an option from our `form_select` dropdown field, we get displayed an `can't be blank` error!

#### Example 10.2: The Checkbox

Similar to the dropdown, we can also use checkboxes for our `form_select` components!

##### Example 10.2.1: Selecting multiple items from an array or hash

On our example page, we define two `form_select` fields, both with the `type: :checkbox` definition. One takes an array as `options` parameter, the other receives a hash.

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-checkbox', key: :array_input, type: :checkbox, options: ['Array Option 1','Array Option 2']
        form_select id: 'my-hash-test-checkbox', key: :hash_input, type: :checkbox, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Now, on our `localhost:3000/example` page, we can check a random number of checkboxes and hit submit to send the checked options to the path we defined in the `form_config`.

##### Example 10.2.2: Initializing it by (multiple) item(s)

Just as with the dropdown `form_select` field, we can `init` our component to have one (or many) options preselected:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-checkbox', key: :array_input, type: :checkbox, options: ['Array Option 1','Array Option 2'], init: ['Array Option 1', 'Array Option 2']
        form_select id: 'my-hash-test-checkbox', key: :hash_input, type: :checkbox, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }, init: ['2']
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

On our example page, we see the preselected checkboxes already checked. We can decide on whether to change this selection or submit it as it is!

##### Example 10.2.3: Mapping to an Active Record Model Column, serialized as an Array

To clean up our code, we can move the `form_select` options to our `TestModel` and serialize them there. We also make the `more_data` attribute obligatory to test our form validation!

```ruby
class TestModel < ApplicationRecord

  serialize :some_data, Array
  serialize :more_data, Array

  validates :more_data, presence: true

  def self.array_options
    ['Array Option 1','Array Option 2']
  end

  def self.hash_options
    { 'my_first_key': 'Hash Option 1', 'my_second_key': 'Hash Option 2' }
  end

end
```

Now, we _prepare_ an instance of our `TestModel` and configure the `options` in our `form_select` component to work on our model methods.

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.some_data = ['Array Option 2']
    @test_model.more_data = ['my_second_key']
  end

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-checkbox', key: :some_data, type: :checkbox, options: TestModel.array_options
        form_select id: 'my-hash-test-checkbox', key: :more_data, type: :checkbox, options: TestModel.hash_options
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Visiting our example page, we see *Array Option 2* and *Hash Option 2* are already checked (as defined in the _prepare_ method) while *Array Option 1* and *Hash Option 1* are not checked. If we now uncheck *Hash Option 2* and try to submit, we receive an error message (`can't be blank`).

Checking *Hash Option 2* again and trying to submit, the error message disappears and our model instance is successfully saved in the database!

#### Example 10.3: The Radio Button

Whilst working similiar to the checkbox, the radio button is designed to only allow for one option to be submitted.

##### Example 10.3.1: Submitting one item from an array or hash

We define our example page to have two `form_select` fields of `type: :radio`. One of them receives an array as `options` parameter, the other a hash:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-radio', key: :array_input, type: :radio, options: ['Array Option 1','Array Option 2']
        form_select id: 'my-hash-test-radio', key: :hash_input, type: :radio, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

Visiting our example page, we can now choose one option from each `form select` field by clicking the radio button fields, choosing e.g. *Array Option 2* and *Hash Option 1*. If we now click the submit button, the route we defined in the `form_config` receives our two options as `array_input: 'Array Option 2', hash_input: '1'`!

##### Example 10.3.2: Initializing it with an item

In this example, our example page looks just like before. The only difference is that we now `init` both form_select components with one of their `options`:

```ruby
class ExamplePage < Matestack::Ui::Page

  def response
    components {
      form form_config, :include do
        form_select id: 'my-array-test-radio', key: :array_input, type: :radio, options: ['Array Option 1','Array Option 2'], init: 'Array Option 1'
        form_select id: 'my-hash-test-radio', key: :hash_input, type: :radio, options: { '1': 'Hash Option 1', '2': 'Hash Option 2' }, init: '2'
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: :my_object,
      method: :post,
      path: :success_form_test_path,
      params: {
        id: 42
      }
    }
  end

end
```

On our example page we find *Array Option 1* and *Hash Option 2* preselected and can just click the submit button to send them to the route defined in `form_config`. Convenient!

##### Example 10.3.3: Mapping it to an Active Record Model Array Enum

We begin with adding an status enum to our `models/test_model.rb`, defined in an array:

```ruby
class TestModel < ApplicationRecord

  enum status: [ :active, :archived ]

end
```

On our example page definition, we create an instance of our `TestModel` and preselect a status for it:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.status = 'active'
  end

  def response
    components {
      form form_config, :include do
        form_input id: 'description', key: :description, type: :text
        form_select id: 'status', key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Now, if we visit our example page on `localhost:3000/example`, we see the preselected status for our `TestModel` instance. We can decide whether to change the status by toggling the radio button, and also can fill in a description in the corresponding input field. After hitting the submit button, both the status and the description get saved with the instance of our `TestModel`!

##### Example 10.3.4: Mapping it to an Active Record Model Hash Enum

Just as in the example above, we define a status in our `models/test_model.rb`. But this time, we define the status enum as a hash!

```ruby
class TestModel < ApplicationRecord

  enum status: [ :active, :archived ]

end
```

The `TestModel` instance gets _prepared_ just as in the example before this one:

```ruby
class ExamplePage < Matestack::Ui::Page

  def prepare
    @test_model = TestModel.new
    @test_model.status = 'active'
  end

  def response
    components {
      form form_config, :include do
        form_input id: 'description', key: :description, type: :text
        form_select id: 'status', key: :status, type: :radio, options: TestModel.statuses.invert, init: TestModel.statuses[@test_model.status]
        form_submit do
          button text: 'Submit me!'
        end
      end
    }
  end

  def form_config
    return {
      for: @test_model,
      method: :post,
      path: :model_form_test_path
    }
  end

end
```

Again, we can visit our example page on `localhost:3000/example` and are welcome by the preselected status of our `TestModel` instance. Changing the value of the status by toggling the radio button and filling in a description plus submitting it works just as before!

#### Example 10.4: The Range Input

Whilst working similiar to the 'text' input, the range input accepts a few more parameters. It accepts also 'min', 'max', 'step', 'list' as optional parameters.

##### Example 10.4.1: Range input with max, min, step set

```ruby
form_input id: 'range-input', type: :range, min: 0, max: 100, step: 1
```

#### Example 10.4.2: Range input with corresponding datalist

To use a datalist for the range input specify the 'list' parameter with the id of the provided datalist

```ruby
form_input id: 'range-input', type: :range, list: 'datalist-id'
datalist id: 'datalist-id' do
  option value: 10
  option value: 20
end
```

#### Example 11: File Upload

In order to perform a single file upload, add this `form_input` component

```ruby
form_input key: :some_file, type: :file
```

In order to perform multiple file uploads, add this `form_input` component

```ruby
form_input key: :some_files, type: :file, multiple: true
```

Don't forget to add the `multiple: true` attribute to your `form_config`!

In order to accept multiple files, you should permit params on your controller like:

`some_controller.rb`
```ruby
#...
params.require(:my_form_wrapper_key).permit(
  :some_file,
  some_files: []
)
#...
```

Please be aware that the `form_input` components with a `type: :file` can not be initialized with a given file.
