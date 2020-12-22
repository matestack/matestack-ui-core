module Matestack::Ui::Core::Form::Submit
  class Base < Matestack::Ui::Core::Component::Dynamic

    def submit_attributes
      html_attributes.merge!({
        "@click.prevent": "$parent.perform",
        "v-bind:class": "{ 'loading': $parent.loading }"
      })
    end

  end
end
