module Matestack::Ui::Core::Optgroup
  class Optgroup < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!(
        disabled: options[:disabled] ||= nil,
        label: options[:label]
      )
    end
  end
end
