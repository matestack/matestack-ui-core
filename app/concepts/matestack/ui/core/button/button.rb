module Matestack::Ui::Core::Button
  class Button < Matestack::Ui::Core::Component::Static
    html_attributes :autofocus, :disabled, :form, :formaction, :formenctype, :formmethod, 
      :formnovalidate, :formtarget, :name, :type, :value
    optional :text
  end
end
