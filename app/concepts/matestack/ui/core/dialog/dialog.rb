module Matestack::Ui::Core::Dialog
  class Dialog < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        "open": options[:open] ||= nil
      })
    end
  end
end
