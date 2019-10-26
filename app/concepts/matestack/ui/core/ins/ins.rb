module Matestack::Ui::Core::Ins
  class Ins < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        cite: options[:cite],
        datetime: options[:datetime]
      })
  end
end