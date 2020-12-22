# Matestack Core Component: Form Submit

The `form_submit` component is Vue.js driven child component of the `form` component and is used to trigger the parent `form` to submit its data.

```ruby
form my_form_config do
  #...
  form_submit do
    button text: "submit"
  end
end
```

All child components `form_*` (including this component) have to be placed within the scope of the parent `form` component, without any other Vue.js driven component like `toggle`, `async` creating a new scope between the child component and the parent form component! Non-Vue.js component can be placed between `form` and `form_*` without issues!

```ruby
# that's working:
form some_form_config do
  form_* key: :foo
  toggle show_on: "some-event" do
    plain "hello!"
  end
end

# that's not working:
form some_form_config do
  toggle show_on: "some-event" do
    form_* key: :foo
  end
end
```

## Parameters

`form_submit` does not take any parameters but yields a given block. This block will be wrapped by a span tag. A click on that span tag and all elements within will submit the form.

## Loading state

If you simply want to disable your submit button, you can use a simple Vue.js binding:

```ruby
form_submit do
  button text: "Submit me!", attributes: { "v-bind:disabled": "loading()" }
end

```

If you want to adjust the submit element more flexible while the form is being submitted, you could use the event mechanism of the form in combination with the `toggle` component:

```ruby
form_submit do
  toggle hide_on: "form_loading", show_on: "form_succeeded, form_failed", init_show: true do
    button text: "Submit me!"
  end
  toggle show_on: "form_loading", hide_on: "form_succeeded, form_failed" do
    button text: "submitting...", disabled: true
  end
end
```

in combination with a form config like this:

```ruby
def my_form_config
  {
    #...
    emit: "form_loading",
    success: {
      emit: "form_succeeded"
    },
    failure: {
      emit: "form_failed"
    }
  }
end

```
