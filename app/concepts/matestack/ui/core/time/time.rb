module Matestack::Ui::Core::Time
  class Time < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        "datetime": options[:datetime] ||= nil
      })
    end

  end
end
