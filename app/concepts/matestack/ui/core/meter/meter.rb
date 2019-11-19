module Matestack::Ui::Core::Meter
  class Meter < Matestack::Ui::Core::Component::Static
    def setup
      @tag_attributes.merge!({
        value: options[:value],
        min: options[:min],
        max: options[:max],
        low: options[:low],
        high: options[:high],
        optimum: options[:optimum]
      })
    end
  end
end
