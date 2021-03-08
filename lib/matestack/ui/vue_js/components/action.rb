module Matestack
  module Ui
    module VueJs
      module Components
        class Action < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-action'

          internal :path, :success, :failure, :notify, :confirm, :confirm_text, :data
          internal method: { as: :action_method }

          def response
            a attributes do
              yield
            end
          end

          def attributes
            {
              href: internal_context.path,
              '@click.prevent': 'perform',
            }
          end

          def config
            {}.tap do |conf|
              conf[:action_path] = internal_context.path
              conf[:method] = internal_context.action_method
              conf[:success] = internal_context.success
              conf[:failure] = internal_context.failure
              conf[:notify] = true if internal_context.notify.nil?
              conf[:confirm] = internal_context.confirm
              conf[:confirm_text] = internal_context.confirm.try(:[], :text) || 'Are you sure?'
              conf[:data] = internal_context.data
            end
          end

        end
      end
    end
  end
end