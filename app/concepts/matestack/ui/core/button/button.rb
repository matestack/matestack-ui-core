module Matestack::Ui::Core::Button
  class Button < Matestack::Ui::Core::Component::Static
    html_attributes :disabled
    optional :text
  end
end
