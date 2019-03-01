module Form::Cell
  class Input < Component::Cell::Static

    # def setup
    #   p @included_config[:init].send(:code)
    # end

    def input_key
      'data["' + options[:key].to_s + '"]'
    end

    def error_key
      'errors["' + options[:key].to_s + '"]'
    end

    def input_wrapper
      case options[:for]
      when nil
        return nil
      when Symbol
        return options[:for]
      when String
        return options[:for]
      end
      if options[:for].respond_to?(:model_name)
        return options[:for].model_name.singular
      end
    end

    def attr_key
      if input_wrapper.nil?
        return options[:key].to_s
      else
        return "#{input_wrapper}.#{options[:key].to_s}"
      end
    end

    def init_value
      unless options[:init].nil?
        return options[:init]
      end

      unless options[:for].nil?
        value = options[:for].send(options[:key])
        if [true, false].include? value
          value ? 1 : 0
        else
          return value
        end
      else
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
end
