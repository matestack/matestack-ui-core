module Matestack::Ui::Core::Output
  class Output < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!(
        name: options[:name],
        for: options[:for],
        form: options[:form]
      )
    end
  end
end
