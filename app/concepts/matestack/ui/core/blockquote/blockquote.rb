module Matestack::Ui::Core::Blockquote
  class Blockquote < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "cite": options[:cite]
        })
    end

  end
end
