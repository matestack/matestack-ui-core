module Matestack::Ui::Core::Map
  class Map < Matestack::Ui::Core::Component::Static
    requires :name

    def setup
      @tag_attributes.merge!({
        name: options[:name]
      })
    end
  end
end
