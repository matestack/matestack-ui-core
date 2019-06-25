module Matestack::Ui::Core::Form::Inline
  class Inline < Matestack::Ui::Core::Component::Static

    def input_key
      'data["' + options[:key].to_s + '"]'
    end

  end
end
