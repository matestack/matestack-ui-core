module Matestack::Ui::Core::Data
  class Data < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        "value": options[:value] ||= nil
      })
    end
  end
end
