module Matestack::Ui::Core::Area
  class Area < Matestack::Ui::Core::Component::Static
    html_attributes :alt, :download, :href, :hreflang, :media, :rel, :shape, :target, :type
    optional :coords
  end
end
