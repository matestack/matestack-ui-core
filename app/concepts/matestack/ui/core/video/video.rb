module Matestack::Ui::Core::Video
  class Video < Matestack::Ui::Core::Component::Static
    html_attributes :autoplay, :controls, :height, :loop, :muted, :poster, :preload, :src, :width

    requires :path, :type

    def setup
      @source = ActionController::Base.helpers.asset_path(path)
      @type = "video/#{type}"
    end

  end
end
