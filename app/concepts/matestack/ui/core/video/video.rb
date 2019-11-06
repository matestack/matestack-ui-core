module Matestack::Ui::Core::Video
  class Video < Matestack::Ui::Core::Component::Static

    REQUIRED_KEYS = [:path, :type]

    def setup
      @tag_attributes.merge!({
        autoplay: options[:autoplay],
        controls: options[:controls],
        height: options[:height],
        loop: options[:loop],
        muted: options[:muted],
        playsinline: options[:playsinline],
        preload: options[:preload],
        width: options[:width]
      })

      @source = ActionController::Base.helpers.asset_path(options[:path])
      @type = "video/#{@options[:type]}"
    end

  end
end
