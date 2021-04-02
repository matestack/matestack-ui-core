# Form Radio

The `form_radio` component is Vue.js driven child component of the `form` component and is used to collect user input.

```ruby
form my_form_config do
  form_radio key: :status, options: { 'active': 1, 'deactive': 0 }, #...
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

### options - required

Can either be an Array or Hash:

**Array usage**

```ruby
form my_form_config do
  form_radio key: :status, options: [0, 1]
end
```

will render:

```markup
<input id="status_0" name="status_0" type="radio" value="0">
<label for="status_0">
0
</label>
<input id="status_1" name="status_1" type="radio" value="1">
<label for="status_1">
1
</label>
```

**Hash usage**

```ruby
form my_form_config do
  form_select key: :status, options: { 'active': 1, 'deactive': 0 }
end
```

will render:

```markup
<input id="status_1" name="status_active" type="radio" value="1">
<label for="status_1">
  active
</label>
<input id="status_0" name="status_deactive" type="radio" value="0">
<label for="status_0">
  deactive
</label>
```

The hash values will be used as values for the options, the keys as displayed values.

**ActiveRecord Enum Mapping**

If you want to use ActiveRecord enums as options for your radio input, you can use the enum class method:

```ruby
class Conversation < ActiveRecord::Base
  enum status: { active: 0, archived: 1 }
end
```

```ruby
form my_form_config do
  form_radio key: :status, options: Conversation.statuses
end
```

### disabled\_values - optional

NOT IMPLEMENTED YET

### init - optional

Defines the init value of the radio input. If mapped to an ActiveRecord model, the init value will be derived automatically from the model instance.

Pass in an Integer:

```ruby
form my_form_config do
  form_radio key: :status, [1,2,3], init: 1
end
```

### placeholder - optional

Defines the placeholder which will be rendered as first, disabled option.

### label - optional

NOT IMPLEMENTED YET

You can also use the `label` component in order to create a label for this input.

## Custom Radio

If you want to create your own radio component, that's easily done since `v.1.3.0`.

* Create your own Ruby component:

`app/matestack/components/my_form_radio.rb`

```ruby
class Components::MyFormRadio < Matestack::Ui::Core::Form::Radio::Base

  vue_js_component_name "my-form-radio"

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
    my_form_radio: Components::MyFormRadio,
    # ...
  )

end
```

* Create the corresponding Vue.js component:

Generic code:

`app/matestack/components/my_form_radio.js`

```javascript
MatestackUiCore.Vue.component('my-form-radio', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formRadioMixin],
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
    // you can access the default initial value via this.props["init_value"]
    // if you need to, you can access your own component config data which added
    // within the prepare method of the corresponding Ruby class
    // this.props["foo"] would be "bar" in this case
  }
});
```

* Don't forget to require the custom component JavaScript according to your JS setup!
* Finally, use it within a `form`:

```ruby
form some_form_config do
  my_form_radio key: :foo, options: [1,2,3]
end
```

