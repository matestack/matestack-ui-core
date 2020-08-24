module Matestack::Ui::Core::Collection::Filter::Input
  class Input < Matestack::Ui::Core::Component::Static
    include Matestack::Ui::Core::Form::HasInputHtmlAttributes

    requires :key, :type
    optional :placeholder, class: { as: :klass }

    def response
      input html_attributes.merge(attributes: {
        "v-model#{'.number' if type == :number}": input_key,
        type: type,
        id: component_id,
        "@keyup.enter": "submitFilter()",
        ref: "filter.#{attr_key}",
        placeholder: placeholder
      })
    end

    def input_key
      'filter["' + key.to_s + '"]'
    end

    def attr_key
      key.to_s
    end

  end
end
