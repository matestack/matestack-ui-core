module Matestack::Ui::Core::Plain
  class Plain < Matestack::Ui::Core::Component::Static

    def show
      html_escape @argument
    end

  end
end
