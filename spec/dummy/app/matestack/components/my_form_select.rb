class Components::MyFormSelect < Matestack::Ui::Core::Form::Select::Base

  vue_js_component_name "my-form-select"

  def response
    div do
      label text: "my select input"
      select select_attributes.merge(class: "select2") do
        render_options
      end
      render_errors
    end
  end

end
