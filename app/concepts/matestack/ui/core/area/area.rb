module Matestack::Ui::Core::Area
  class Area < Matestack::Ui::Core::Component::Static
    optional :alt, :coords, :download, :href, :hreflang, :media, :rel, :shape, :target, :type
    
    def setup
      @tag_attributes.merge!({
        alt: alt,
        coords: coords.join(','),
        download: download,
        href: href,
        hreflang: hreflang,
        media: media,
        rel: rel,
        shape: shape,
        target: target,
        type: type
      })
    end
  end
end
