module Matestack::Ui::Core::Map
  class Map < Matestack::Ui::Core::Component::Static
    REQUIRED_KEYS = [:name]

    def setup
      @tag_attributes.merge!({
        name: options[:name]
      })
    end
  end
end
