module Absolute::Cell
  class Absolute < Component::Cell::Static

    def setup
      style = "position: absolute;"
      style << " top: #{options[:top]}px;" if options[:top]
      style << " left: #{options[:left]}px;" if options[:left]
      style << " right: #{options[:right]}px;" if options[:right]
      style << " bottom: #{options[:bottom]}px;" if options[:bottom]
      style << " z-index: #{options[:z]};" if options[:z]
      @tag_attributes.merge!({
        style: style
      })
    end

  end
end
