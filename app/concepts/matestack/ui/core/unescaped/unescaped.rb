module Matestack::Ui::Core::Unescaped
  class Unescaped < Matestack::Ui::Core::Component::Static
    def show
      @argument.html_safe
    end
  end
end
