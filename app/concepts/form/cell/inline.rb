module Form::Cell
  class Inline < Component::Cell::Static

    def input_key
      'data["' + options[:key].to_s + '"]'
    end
    
  end
end
