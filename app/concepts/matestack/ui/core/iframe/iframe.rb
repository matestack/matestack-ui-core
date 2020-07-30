module Matestack::Ui::Core::Iframe
  class Iframe < Matestack::Ui::Core::Component::Static
    html_attributes :src, :height, :width, :srcdoc
    optional :text
  end
end
