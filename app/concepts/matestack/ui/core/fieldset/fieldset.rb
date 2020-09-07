module Matestack::Ui::Core::Fieldset
  class Fieldset < Matestack::Ui::Core::Component::Static
    html_attributes :disabled, :form, :name
    optional :text
  end
end
