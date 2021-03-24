class Components::MyFormInput < Matestack::Ui::Core::Form::Input::Base

  vue_js_component_name "my-form-input"

  def prepare
    # optionally add some data here, which will be accessible within your Vue.js component
    @component_config[:foo] = "bar"
  end

  def response
    div do
      label text: "my form input"
      input input_attributes.merge(class: "flatpickr")
      render_errors
    end
  end

end
