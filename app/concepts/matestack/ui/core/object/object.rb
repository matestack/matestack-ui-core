module Matestack::Ui::Core::Object
  class Object < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        width: options[:width],
        height: options[:height],
        data: options[:data],
        form: options[:form],
        name: options[:name],
        type: options[:type],
        usemap: options[:usemap]
      })
    end
  end
end
