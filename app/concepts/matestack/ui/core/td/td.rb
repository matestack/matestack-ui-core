module Matestack::Ui::Core::Td
  class Td < Matestack::Ui::Core::Component::Static
    html_attributes :colspan, :headers, :rowspan
    optional :text
  end
end
