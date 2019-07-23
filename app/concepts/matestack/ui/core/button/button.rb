module Matestack::Ui::Core::Button
  class Button < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "disabled": options[:disabled] ||= nil
      })
    end

  end
end
