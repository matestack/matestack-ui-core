module Matestack::Ui::Core::Label
  class Label < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        for: options[:for],
        form: options[:form]
      })
    end
  end
end
