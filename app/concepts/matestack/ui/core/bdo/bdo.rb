module Matestack::Ui::Core::Bdo
  class Bdo < Matestack::Ui::Core::Component::Static
    REQUIRED_KEYS = [:dir]

    def setup
      @tag_attributes.merge!({
        "dir": options[:dir]
      })
    end
  end
end
