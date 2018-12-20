module Input::Cell
  class Input < Component::Cell::Static

    def input_key
      'data["' + options[:key].to_s + '"]'
    end

    def error_key
      'errors["' + options[:key].to_s + '"]'
    end

    def attr_key
      options[:key].to_s
    end

  end
end
