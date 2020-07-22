module Matestack::Ui::Core::Form::Input
  class Input < Matestack::Ui::Core::Component::Static

    html_attributes :accept, :alt, :autocomplete, :autofocus, :checked, :dirname, :disabled, :form, :formaction, 
      :formenctype, :formmethod, :formnovalidate, :formtarget, :height, :list, :max, :maxlength, :min, :minlength, 
      :multiple, :name, :pattern, :placeholder, :readonly, :required, :size, :src, :step, :type, :value, :width

    requires :key, :type
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }

    def response
      label text: input_label if input_label
      input html_attributes.merge(attributes: vue_attributes)
      span class: 'errors', attributes: { 'v-if': error_key } do
        span class: 'error', text: '{{ error }}', attributes: { 'v-for': "error in #{error_key}" }
      end
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        "@change": change_event,
        ref: "input.#{attr_key}",
        'init-value': init_value
      }).merge(
        type != :file ? { "#{v_model_type}": input_key } : {}
      ) # file inputs are readonly, no v-model possible
    end

    def v_model_type
      if type == :number || init_value.is_a?(Integer)
        'v-model.number'
      else
        'v-model'
      end
    end

    def change_event
      "inputChanged('#{attr_key}'); #{ "filesAdded('#{attr_key}');" if type == :file }".strip
    end

    def custom_options_validation
      raise "included form config is missing, please add ':include' to parent form component" if @included_config.nil?
    end

    def input_key
      "data['#{key.to_s}']"
    end

    def error_key
      "errors['#{key.to_s}']"
    end

    def input_wrapper
      case input_for
      when nil
        return nil
      when Symbol, String
        return input_for
      end
      if input_for.respond_to?(:model_name)
        return input_for.model_name.singular
      end
    end

    def attr_key
      if input_wrapper.nil?
        return "#{key.to_s}#{'[]' if multiple}"
      else
        return "#{input_wrapper}.#{key.to_s}#{'[]' if multiple}"
      end
    end

    def init_value
      return init unless init.nil?

      unless input_for.nil?
        value = parse_value(input_for.send key)
      else
        unless @included_config.nil? && @included_config[:for].nil?
          if @included_config[:for].respond_to?(key)
            value = parse_value(@included_config[:for].send key)
          else
            @included_config[:for][key] if @included_config[:for].is_a?(Hash)
          end
        end
      end
    end

    private

    def parse_value(value)
      if [true, false].include? value
        value ? 1 : 0
      else
        return value
      end
    end

  end
end
