module Matestack::Ui::Core::Iframe
  class Iframe < Matestack::Ui::Core::Component::Static
    html_attributes :allow, :allowfullscreen, :allowpaymentrequest, :height, :name, 
      :referrerpolicy, :sandbox, :src, :srcdoc, :width
    optional :text
  end
end
