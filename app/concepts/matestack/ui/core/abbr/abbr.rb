module Matestack::Ui::Core::Abbr
  class Abbr < Matestack::Ui::Core::Component::Static
    requires :title
    optional :text

    def setup
      @tag_attributes.merge!({
        "title": title
      })
    end

  end
end
