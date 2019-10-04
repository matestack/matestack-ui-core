module Matestack::Ui::Core::Youtube
  class Youtube < Matestack::Ui::Core::Component::Static

    REQUIRED_KEYS = [:yt_id, :height, :width]

    def setup
      url = 'https://www.youtube.com/embed/'
      url = 'https://www.youtube-nocookie.com/embed/' if options[:privacy_mode] == true
      url << options[:yt_id]
      url << '?' unless options[:no_controls] != true and options[:start_at].nil?
      url << 'controls=0' if options[:no_controls] == true
      url << '&amp;' if (options[:no_controls] != nil) and (options[:start_at] != nil)
      url << "start=#{options[:start_at]}" unless options[:start_at].nil?

      @tag_attributes.merge!({
        'src': url,
        'allow': 'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture',
        'allowfullscreen': '',
        'frameborder': 0,
        'height': options[:height],
        'width': options[:width]
      })
    end

  end
end
