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
          m_form: Matestack::Ui::VueJs::Components::Form::Form,
          form_input: Matestack::Ui::VueJs::Components::Form::Input,
          form_textarea: Matestack::Ui::VueJs::Components::Form::Textarea,
          form_checkbox: Matestack::Ui::VueJs::Components::Form::Checkbox,
          form_radio: Matestack::Ui::VueJs::Components::Form::Radio,
          form_select: Matestack::Ui::VueJs::Components::Form::Select,
        )

      end
    end
  end
end