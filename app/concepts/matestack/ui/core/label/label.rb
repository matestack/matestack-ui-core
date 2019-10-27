module Matestack::Ui::Core::Label
  class Label < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        for: options[:for]
      })
    end
  end
end
