# Input Component API

The `form_input` component is Vue.js driven child component of the `matestack_form` component and is used to collect user input.

```ruby
matestack_form my_form_config do
  form_input key: :foo, type: :text, #...
end
```

All child components `form_*` \(including this component\) have to be placed within the scope of the parent `form` component, without any other Vue.js driven component like `toggle`, `async` creating a new scope between the child component and the parent form component! Non-Vue.js component can be placed between `form` and `form_*` without issues!

```ruby
# that's working:
matestack_form some_form_config do
  form_* key: :foo
  toggle show_on: "some-event" do
    plain "hello!"
  end
end

# that's not working:
matestack_form some_form_config do
  toggle show_on: "some-event" do
    form_* key: :foo
  end
end
```

## Parameters

### key - required

Defines the key which should be used when posting the form data to the server.

### type - required

Pass in as symbol. Defines the type of the `input`. All HTML input types are supported.

### placeholder

Defines the placeholder.

### label

Defines the label which will be rendered right before the input tag. You can also use the `label` component in order to create more complex label structures.

### required

If set to true, HTML validations will be triggered on form submit.

### init

If given, this value will be the initial value of the input. If used in an edit form of a given ActiveRecord model, the init value will be automatically derived from the model itself.

## File Upload

Don't forget to add the `multipart: true` attribute to your `form_config` in order to enable file uploads!

In order to perform a single file upload, add this `form_input` component

```ruby
form_input key: :some_file, type: :file
```

In order to perform multiple file uploads, add this `form_input` component

```ruby
form_input key: :some_files, type: :file, multiple: true
```

Don't forget to add the `multiple: true` attribute to your `form_config` in order to enable multi file upload!

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

## Range Input

Whilst working similiar to the 'text' input, the range input accepts a few more parameters. It accepts also 'min', 'max', 'step', 'list' as optional parameters.

**with max, min, step set**

```ruby
form_input id: 'range-input', type: :range, min: 0, max: 100, step: 1
```

**with corresponding datalist**

To use a datalist for the range input specify the 'list' parameter with the id of the provided datalist

```ruby
form_input id: 'range-input', type: :range, list: 'datalist-id'
datalist id: 'datalist-id' do
  option value: 10
  option value: 20
end
```

## Custom Input

If you want to create your own input component, that's easily done since `v.1.3.0`. Imagine, you want to use `flatpickr` and therefore need to adjust the `input` rendering and need to initialize the third party library:

* Create your own Ruby component:

`app/matestack/components/my_form_input.rb`

```ruby
class Components::MyFormInput < Matestack::Ui::VueJs::Components::Form::Input

  vue_name "my-form-input"

  # optionally add some data here, which will be accessible within your Vue.js component
  def vue_props
    {
      foo: "bar"
    }
  end

  def response
    # exactly one root element is required since this is a Vue.js component template
    div do
      label "my form input"
      input input_attributes.merge(class: "flatpickr")
      render_errors
    end
  end

end
```

* Create the corresponding Vue.js component:

Generic code:

```javascript
Vue.component('my-form-input', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formInputMixin],
  data() {
    return {};
  },
  methods: {
    afterInitialize: function(value){
      // optional: if you need to modify the initial value
      // use this.setValue(xyz) in order to change the value
      // this method can be used in other methods or mounted hook of this component as well!
      this.setValue(xyz)
    }
  },
  mounted: function(){
    // use/initialize any third party library here
    // you can access the default initial value via this.componentConfig["init_value"]
    // if you need to, you can access your own component config data which added
    // within the prepare method of the corresponding Ruby class
    // this.componentConfig["foo"] would be "bar" in this case
  }
});
```

In order to support the `flatpickr` library, you would do something like this:

`app/matestack/componenst/my_form_input.js`

```javascript
Vue.component('my-form-input', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formInputMixin],
  data() {
    return {};
  },
  mounted: function(){
    // flatpickr needs to be required according to your JS setup
    flatpickr(this.$el.querySelector('.flatpickr'), {
      defaultDate: this.props["init_value"],
      enableTime: true
    });
  }
});
```

* Don't forget to require the custom component JavaScript according to your JS setup!
* Finally, use it within a `form`:

```ruby
matestack_form some_form_config do
  Components::MyFormInput.(key: :foo, type: :text)
end
```

