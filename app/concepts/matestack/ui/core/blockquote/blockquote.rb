module Matestack::Ui::Core::Blockquote
  class Blockquote < Matestack::Ui::Core::Component::Static
    html_attributes :cite
    optional :text
  end
end
