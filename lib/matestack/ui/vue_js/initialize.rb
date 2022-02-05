module Matestack::Ui::VueJs::Initialize

  include Matestack::Ui::VueJs::Components

  # give easy access to vue data attributes
  def vue
    Matestack::Ui::VueJs::VueAttributes
  end

end
