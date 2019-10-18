module Matestack::Ui::Core::Fieldset
  class Fieldset < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        disabled: options[:disabled]
      })
    end
  end
end