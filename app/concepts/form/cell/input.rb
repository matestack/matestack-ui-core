module Form::Cell
  class Input < Component::Cell::Static

    REQUIRED_KEYS = [:key, :type]

    def custom_options_validation
      raise "included form config is missing, please add ':include' to parent form component" if @included_config.nil?
    end

    def input_key
      'data["' + options[:key].to_s + '"]'
    end

    def error_key
      'errors["' + options[:key].to_s + '"]'
    end

    def attr_key
      options[:key].to_s
    end

    def init_value
      unless options[:init].nil?
        return options[:init]
      end

      unless @included_config.nil? && @included_config[:for].nil?
        if @included_config[:for].respond_to?(options[:key])
          return @included_config[:for].send(options[:key])
        else
          if @included_config[:for].is_a?(Symbol) || @included_config[:for].is_a?(String)
            return nil
          end
          if @included_config[:for].is_a?(Hash)
            return @included_config[:for][options[:key]]
          end
        end
      end
    end

  end
end
