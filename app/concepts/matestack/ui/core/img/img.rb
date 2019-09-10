module Matestack::Ui::Core::Img
  class Img < Matestack::Ui::Core::Component::Static

    def setup
      @tag_attributes.merge!({
        src: ActionController::Base.helpers.asset_path(options[:path]),
        height: options[:height],
        width: options[:width],
        alt: options[:alt]
      })
    end

  end
end
