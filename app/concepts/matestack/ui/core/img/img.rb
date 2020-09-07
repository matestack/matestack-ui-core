module Matestack::Ui::Core::Img
  class Img < Matestack::Ui::Core::Component::Static
    html_attributes :alt, :crossorigin, :height, :ismap, :longdesc, :referrerpolicy, 
      :sizes, :src, :srcset, :usemap, :width

    optional :path

    def img_attributes
      html_attributes.tap do |attributes|
        attributes[:src] = ActionController::Base.helpers.asset_path(path) if path
      end
    end

  end
end
