module Matestack
  module Ui
    module Core
      class Component < Base
        include Matestack::Ui::Core::ComponentRegistry
        # include MatestackUi::Components::Registry if defined?(MatestackUi::Components)   
      end
    end
  end
end