module Matestack
  module Ui
    module VueJs
      module Components

          def toggle(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Toggle.(text, options, &block)
          end

          def onclick(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Onclick.(text, options, &block)
          end

          def transition(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Transition.(text, options, &block)
          end

          def async(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Async.(text, options, &block)
          end

          def action(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Action.(text, options, &block)
          end

          def cable(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Cable.(text, options, &block)
          end

          def matestack_form(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Form.(text, options, &block)
          end

          def form_input(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Input.(text, options, &block)
          end

          def form_textarea(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Textarea.(text, options, &block)
          end

          def form_checkbox(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Checkbox.(text, options, &block)
          end

          def form_radio(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Radio.(text, options, &block)
          end

          def form_select(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Form::Select.(text, options, &block)
          end

          def collection_content(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Content.(text, options, &block)
          end

          def collection_filter(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Filter.(text, options, &block)
          end

          def collection_filter_reset(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::FilterReset.(text, options, &block)
          end

          def collection_order(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Order.(text, options, &block)
          end

          def collection_order_toggle(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::OrderToggle.(text, options, &block)
          end

          def collection_order_toggle_indicator(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::OrderToggleIndicator.(text, options, &block)
          end

          def collection_content_next(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Next.(text, options, &block)
          end

          def collection_content_previous(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Previous.(text, options, &block)
          end

          def collection_content_page_link(text=nil, options=nil, &block)
             Matestack::Ui::VueJs::Components::Collection::Page.(text, options, &block)
          end


      end
    end
  end
end
