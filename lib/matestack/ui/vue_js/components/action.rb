module Matestack
  module Ui
    module VueJs
      module Components
        class Action < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-action'

          optional :path, :success, :failure, :notify, :confirm, :confirm_text, :data

          def response
            a attributes do
              yield
            end
          end

          def attributes
            {
              href: ctx.path,
              '@click.prevent': 'perform',
            }.merge(options)
          end

          def config
            {}.tap do |conf|
              conf[:action_path] = ctx.path
              conf[:method] = action_method
              conf[:success] = ctx.success
              conf[:failure] = ctx.failure
              conf[:notify] = true if ctx.notify.nil?
              conf[:confirm] = ctx.confirm
              conf[:confirm_text] = ctx.confirm.try(:[], :text) || 'Are you sure?'
              conf[:data] = ctx.data
            end
          end

          def action_method
            @action_method ||= options.delete(:method)
          end

        end
      end
    end
  end
end