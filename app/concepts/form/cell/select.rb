module Form::Cell
  class Select < Component::Cell::Static

    def input_key
      'data["' + options[:key].to_s + '"]'
    end

    def error_key
      'errors["' + options[:key].to_s + '"]'
    end

    def attr_key
      options[:key].to_s
    end

    def option_values
      values = options[:options] if options[:options].is_a?(Array)
      values = options[:options].values if options[:options].is_a?(Hash)
      return values
    end

    def options_type
      return Integer if option_values.first.is_a?(Integer)
      return String if option_values.first.is_a?(String)
    end

    def model_binding

      if option_values.first.is_a?(Integer)
        return "v-model.number"
      else
        return "v-model"
      end
    end

    def init_value
      unless options[:init].nil?
        return options[:init]
      end

      unless @included_config.nil? && @included_config[:for].nil?
        value = @included_config[:for].send(options[:key])
        if [true, false].include? value
          value ? 1 : 0
        else
          return value
        end
      end
    end


  end
end
