module Matestack::Ui::Core::Collection::Filter::Input
  class Input < Matestack::Ui::Core::Component::Static

    def input_key
      'filter["' + options[:key].to_s + '"]'
    end

    def attr_key
      return options[:key].to_s
    end

  end
end
