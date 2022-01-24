module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class NestedForm < Matestack::Ui::VueJs::Components::Form::Form
            vue_name 'matestack-ui-core-form-nested-form'

            optional :fields_for, :reject_blank

            attr_accessor :prototype_template

            # setup form context to allow child components like inputs to access the form configuration
            def initialize(html_tag = nil, text = nil, options = {}, &block)
              previous_form_context = Matestack::Ui::VueJs::Components::Form::Context.form_context
              if !previous_form_context.nil?
                @is_nested_form = true
                @parent_form_context = previous_form_context
              end
              Matestack::Ui::VueJs::Components::Form::Context.form_context = self
              super(html_tag, text, options, &block)
              Matestack::Ui::VueJs::Components::Form::Context.form_context = previous_form_context
            end

            def component_id
              "matestack-form-fields-for-#{context.fields_for}-#{SecureRandom.hex}"
            end

            def response
              div class: "matestack-form-fields-for", "v-show": "vc.hideNestedForm != true", id: options[:id] do
                form_input key: context.for&.class&.primary_key, type: :hidden # required for existing model mapping
                form_input key: :_destroy, type: :hidden, init: true if context.reject_blank == true
                yield
              end
            end

            def vue_props
              super.merge({
                fields_for: ctx.fields_for,
                primary_key: for_object_primary_key
              })
            end

            def is_nested_form?
              true
            end

            def parent_form_context
              @parent_form_context
            end

          end
        end
      end
    end
  end
end
