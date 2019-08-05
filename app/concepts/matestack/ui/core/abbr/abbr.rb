module Matestack::Ui::Core::Abbr
  class Abbr < Matestack::Ui::Core::Component::Static
    REQUIRED_KEYS = [:title]

    def setup
      @tag_attributes.merge!({
        "title": options[:title]
      })
    end

  end
end
