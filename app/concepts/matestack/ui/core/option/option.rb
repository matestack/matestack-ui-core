module Matestack::Ui::Core::Option
  class Option < Matestack::Ui::Core::Component::Static
    html_attributes :disabled, :selected, :label, :value
    optional :text
  end
end
