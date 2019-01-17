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

    def attr_key
      options[:key].to_s
    end

    def init_value
      unless options[:init].nil?
        return options[:init]
      end

      unless @included_config.nil? && @included_config[:for].nil?
        return @included_config[:for].send(options[:key])
      end
    end

  end
end
