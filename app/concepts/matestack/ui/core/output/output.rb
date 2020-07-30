module Matestack::Ui::Core::Output
  class Output < Matestack::Ui::Core::Component::Static
    html_attributes :name, :for, :form
    optional :text
  end
end
