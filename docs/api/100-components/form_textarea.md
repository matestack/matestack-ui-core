# Matestack Core Component: Form Textarea

```ruby
form my_form_config do
  form_textarea key: :foo, #...
end
```

## Parameters

### key - required

Defines the key which should be used when posting the form data to the server.

### placeholder - optional

Defines the placeholder.

### label - optional

Defines the label which will be rendered right before the textarea tag. You can also use the `label` component in order to create more complex label structures.

### required - optional

If set to true, HTML validations will be triggered on form submit.

### init - optional

If given, this value will be the initial value of the input. If used in an edit form of a given ActiveRecord model, the init value will be automatically derived from the model itself.

## Custom Textarea

If you want to create your own textarea component, that's easily done since `v.1.3.0`.

* Create your own Ruby component:

`app/matestack/components/my_form_textarea.rb`

```ruby
class Components::MyFormTextarea < Matestack::Ui::Core::Form::Textarea::Base

  vue_js_component_name "my-form-textarea"

  def prepare
    # optionally add some data here, which will be accessible within your Vue.js component
    @component_config[:foo] = "bar"
  end

  def response
    # exactly one root element is required since this is a Vue.js component template
    div do
      label text: "my form textarea"
      textarea textarea_attributes
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
    my_form_textarea: Components::MyFormTextarea,
    # ...
  )

end
```

* Create the corresponding Vue.js component:

`app/matestack/componenst/my_form_textarea.js`

```javascript
MatestackUiCore.Vue.component('my-form-textarea', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formTextareaMixin],
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
  my_form_textarea key: :foo
end
```

