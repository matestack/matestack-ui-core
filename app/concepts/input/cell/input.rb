module Input::Cell
  class Input < Component::Cell::Static


    def input_key
      'data["' + options[:key].to_s + '"]'
    end
  end
end
