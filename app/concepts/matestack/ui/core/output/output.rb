module Matestack::Ui::Core::Output
  class Output < Matestack::Ui::Core::Component::Static
    html_attributes :for, :form, :name
    optional :text
  end
end
