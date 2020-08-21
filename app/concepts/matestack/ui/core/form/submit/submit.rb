module Matestack::Ui::Core::Form::Submit
  class Submit < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "@click.prevent": "perform",
        "v-bind:class": "{ 'loading': loading }"
        })
    end

  end
end
