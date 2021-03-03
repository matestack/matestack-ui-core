module Matestack
  module Ui
    module VueJs
      module Registry

        Matestack::Ui::Component.register(
          toggle: Matestack::Ui::VueJs::Components::Toggle,
          onclick: Matestack::Ui::VueJs::Components::Onclick,
          transition: Matestack::Ui::VueJs::Components::Transition,
          async: Matestack::Ui::VueJs::Components::Async,
          action: Matestack::Ui::VueJs::Components::Action,
          cable: Matestack::Ui::VueJs::Components::Cable,
        )

      end
    end
  end
end