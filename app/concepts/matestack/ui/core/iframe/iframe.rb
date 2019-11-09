module Matestack::Ui::Core::Iframe
  class Iframe < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        src: options[:src],
        height: options[:height],
        width: options[:width],
        srcdoc: options[:srcdoc]
      })
    end

  end
end
