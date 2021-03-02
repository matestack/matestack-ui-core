module Matestack
  module Ui
    module VueJs
      module Registry

        Matestack::Ui::Component.register(
          toggle: Matestack::Ui::VueJs::Components::Toggle,
          onclick: Matestack::Ui::VueJs::Components::Onclick,
        )

      end
    end
  end
end