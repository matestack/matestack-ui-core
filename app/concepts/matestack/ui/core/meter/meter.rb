module Matestack::Ui::Core::Meter
  class Meter < Matestack::Ui::Core::Component::Static
    html_attributes :form, :high, :low, :max, :min, :optimum, :value
  end
end
