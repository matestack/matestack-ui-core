module Matestack::Ui::Core::Collection::Filter::Select
  class Select < Matestack::Ui::Core::Component::Static

    requires :key
    optional :placeholder, options: { as: :select_options }

    def setup
      if options[:type].nil?
        options[:type] = :dropdown #nothing else supported at the moment
      end
    end

    def select_attributes
      html_attributes.merge!({
        "v-model#{'.number' if options[:type] == :number}": input_key,
        type: options[:type],
        id: component_id,
        "@keyup.enter": "submitFilter()",
        "@change": "$forceUpdate()",
        ref: "filter.#{key.to_s}",
        placeholder: placeholder
      })
    end

    def input_key
      'filter["' + key.to_s + '"]'
    end

  end
end
