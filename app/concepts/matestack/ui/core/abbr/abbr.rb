module Matestack::Ui::Core::Abbr
  class Abbr < Matestack::Ui::Core::Component::Static
    requires :title

    def setup
      @tag_attributes.merge!({
        "title": options[:title]
      })
    end

  end
end
