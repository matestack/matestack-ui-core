module Matestack::Ui::Core::Option
  class Option < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!(
        disabled: options[:disabled] ||= nil,
        selected: options[:selected] ||= nil,
        label: options[:label],
        value: options[:value]
      )
    end
  end
end
