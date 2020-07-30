module Matestack::Ui::Core::Label
  class Label < Matestack::Ui::Core::Component::Static
    html_attributes :for, :form
    optional :text
  end
end
