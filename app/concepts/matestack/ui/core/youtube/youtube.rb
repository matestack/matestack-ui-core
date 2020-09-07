module Matestack::Ui::Core::Youtube
  class Youtube < Matestack::Ui::Core::Component::Static
    html_attributes :allow, :allowfullscreen, :allowpaymentrequest, :height, :name, 
      :referrerpolicy, :sandbox, :src, :srcdoc, :width

    requires :youtube_id
    optional :privacy_mode, :no_controls, :start_at

    def setup
      url = privacy_mode ? 'https://www.youtube-nocookie.com/embed/' : 'https://www.youtube.com/embed/'
      @uri = URI("#{url}#{youtube_id}")
      @uri.query = { 
        controls: (no_controls ? 0 : 1),
        start: start_at
      }.to_query
    end

    def youtube_attributes
      html_attributes.merge(
        src: @uri.to_s,
        allow: 'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture',
        allowfullscreen: '',
        frameborder: 0,
      )
    end

  end
end
