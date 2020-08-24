module Matestack::Ui::Core::Th
  class Th < Matestack::Ui::Core::Component::Static
    html_attributes :abbr, :colspan, :headers, :rowspan, :scope
    optional :text
  end
end
