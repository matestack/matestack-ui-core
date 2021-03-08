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
          collection_content: Matestack::Ui::VueJs::Components::Collection::Content,
          collection_filter: Matestack::Ui::VueJs::Components::Collection::Filter,
          collection_order: Matestack::Ui::VueJs::Components::Collection::Order,
          collection_next: Matestack::Ui::VueJs::Components::Collection::Next,
          collection_previous: Matestack::Ui::VueJs::Components::Collection::Previous,
          collection_page: Matestack::Ui::VueJs::Components::Collection::Page,
        )

      end
    end
  end
end