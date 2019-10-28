module Matestack::Ui::Core::Param
  class Param < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        name: options[:name],
        value: options[:value]
      })
    end
  end
end
