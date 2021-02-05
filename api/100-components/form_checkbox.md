# Matestack Core Component: Form Checkbox

The `form_checkbox` component is Vue.js driven child component of the `form` component and is used to collect user input.

```ruby
form my_form_config do
  form_checkbox key: :status, #...
end
```

All child components `form_*` \(including this component\) have to be placed within the scope of the parent `form` component, without any other Vue.js driven component like `toggle`, `async` creating a new scope between the child component and the parent form component! Non-Vue.js component can be placed between `form` and `form_*` without issues!

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

### key - required

Defines the key which should be used when posting the form data to the server.

### options - optional

Can either be nil, an Array or Hash:

**When not given**

```ruby
form my_form_config do
  form_checkbox key: :status, label: "Active"
end
```

will render a single checkbox which can switch between `true` and `false` as value for the given key. Will be `nil` initially. The boolean value \(or nil\) will be sent to the server when submitting the form.

**Array usage**

```ruby
form my_form_config do
  form_checkbox key: :status, options: [0, 1]
end
```

will render a collection of checkboxes and their corresponding labels.

Multiple checkboxes can be selected. Data will be sent as an Array of selected values to the server when submitting the form.

**Hash usage**

```ruby
form my_form_config do
  form_checkbox key: :status, options: { 'active': 1, 'deactive': 0 }
end
```

will render a collection of checkboxes and their corresponding labels.

The hash values will be used as values for the checkboxes, the keys as displayed label values.

Multiple checkboxes can be selected. Data will be sent as an Array of selected values to the server when submitting the form.

**ActiveRecord Enum Mapping**

If you want to use ActiveRecord enums as options for your radio input, you can use the enum class method:

```ruby
class Conversation < ActiveRecord::Base
  enum status: { active: 0, archived: 1 }
end
```

```ruby
form my_form_config do
  form_checkbox key: :status, options: Conversation.statuses
end
```

Multiple checkboxes can be selected. Data will be sent as an Array of selected values to the server when submitting the form.

### disabled\_values - optional

NOT IMPLEMENTED YET

### init - optional

NOT IMPLEMENTED YET

### label - optional

An applied label is only visible, when using a single checkbox without options.

You can also use the `label` component in order to create a label for this input.

## Custom Checkbox

If you want to create your own radio component, that's easily done since `v.1.3.0`.

* Create your own Ruby component:

`app/matestack/components/my_form_checkbox.rb`

```ruby
class Components::MyFormCheckbox < Matestack::Ui::Core::Form::Checkbox::Base

  vue_js_component_name "my-form-checkbox"

  def prepare
    # optionally add some data here, which will be accessible within your Vue.js component
    @component_config[:foo] = "bar"
  end

  def response
    # exactly one root element is required since this is a Vue.js component template
    div class: "your-custom-markup" do
      render_options
      render_errors
    end
  end

end
```

* Register your component:

`app/matestack/components/registry.rb`

```ruby
module Components::Registry

  Matestack::Ui::Core::Component::Registry.register_components(
    # ...
    my_form_checkbox: Components::MyFormCheckbox,
    # ...
  )

end
```

* Create the corresponding Vue.js component:

Generic code:

`app/matestack/components/my_form_checkbox.js`

```javascript
MatestackUiCore.Vue.component('my-form-checkbox', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formCheckboxMixin],
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

* Don't forget to require the custom component JavaScript according to your JS setup!
* Finally, use it within a `form`:

```ruby
form some_form_config do
  my_form_checkbox key: :foo, options: [1,2,3]
end
```

