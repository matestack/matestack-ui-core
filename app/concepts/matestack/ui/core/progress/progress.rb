module Matestack::Ui::Core::Progress
  class Progress < Matestack::Ui::Core::Component::Static

    requires :max

    def setup
      @tag_attributes.merge!({
         'value': options[:value] ||= 0,
         'max': options[:max]
      })
    end

  end
end
