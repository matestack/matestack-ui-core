module Matestack::Ui::Core::Q
  class Q < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "cite": options[:cite]
        })
    end

  end
end
