module Matestack::Ui::Core::Meter
  class Meter < Matestack::Ui::Core::Component::Static
    html_attributes :value, :min, :max, :low, :high, :optimum
  end
end
