module Matestack::Ui::Core::Option
  class Option < Matestack::Ui::Core::Component::Static
    html_attributes :disabled, :label, :selected, :value
    optional :text
  end
end
