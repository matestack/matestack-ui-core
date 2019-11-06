module Matestack::Ui::Core::Area
  class Area < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        alt: options[:alt],
        coords: options[:coords].join(','),
        download: options[:download],
        href: options[:href],
        hreflang: options[:hreflang],
        media: options[:media],
        rel: options[:rel],
        shape: options[:shape],
        target: options[:target],
        type: options[:type]
      })
    end
  end
end
