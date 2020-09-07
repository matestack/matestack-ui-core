module Matestack::Ui::Core::Link
  class Link < Matestack::Ui::Core::Component::Static
    html_attributes :download, :href, :hreflang, :media, :ping, :referrerpolicy, :rel, :target, :type

    optional :text, :path, params: { as: :link_params }

    def link_attributes
      html_attributes.tap do |attributes|
        attributes[:href] = link_path if path
      end
    end

    def link_path
      if path.is_a?(Symbol)
        return ::Rails.application.routes.url_helpers.send(path, link_params)
      end
      if path.is_a?(String)
        return path
      end
    end

  end
end
