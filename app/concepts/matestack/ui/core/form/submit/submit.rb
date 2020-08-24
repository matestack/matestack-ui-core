module Matestack::Ui::Core::Form::Submit
  class Submit < Matestack::Ui::Core::Component::Static

    def submit_attributes
      html_attributes.merge!({
        "@click.prevent": "perform",
        "v-bind:class": "{ 'loading': loading }"
      })
    end

  end
end
