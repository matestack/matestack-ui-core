module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Form < Matestack::Ui::VueJs::Vue
            vue_name 'matestack-ui-core-form'

            optional :for, :path, :success, :failure, :multipart, :emit, :delay, :errors

            # setup form context to allow child components like inputs to access the form configuration
            def initialize(html_tag = nil, text = nil, options = {}, &block)
              previous_form_context = Matestack::Ui::VueJs::Components::Form::Context.form_context
              Matestack::Ui::VueJs::Components::Form::Context.form_context = self
              super(html_tag, text, options, &block)
              Matestack::Ui::VueJs::Components::Form::Context.form_context = previous_form_context
            end

            def response
              form attributes do
                yield
              end
            end

            def attributes
              {
                class: 'matestack-form',
                'v-bind:class': "{ 'has-errors': hasErrors(), loading: loading }",
                '@submit.prevent': 'perform',
              }
            end

            def config
              {
                for: for_attribute,
                submit_path: ctx.path,
                method: form_method,
                success: ctx.success,
                failure: ctx.failure,
                multipart: !!ctx.multipart,
                emit: ctx.emit,
                delay: ctx.delay,
              }
            end

            def for_attribute
              return for_option.model_name.singular if for_option.respond_to?(:model_name)
              for_option
            end

            def for_option
              @for_option ||= ctx.for
            end

            def form_method
              @form_method ||= options.delete(:method)
            end

          end
        end
      end
    end
  end
end