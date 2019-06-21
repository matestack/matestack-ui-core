module Matestack::Ui::Core::Form::Input
  class Input < Matestack::Ui::Core::Component::Static

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
          if @included_config[:for].respond_to?(options[:key])
            value = @included_config[:for].send(options[:key])
            if [true, false].include? value
              value ? 1 : 0
            else
              return value
            end
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
end
