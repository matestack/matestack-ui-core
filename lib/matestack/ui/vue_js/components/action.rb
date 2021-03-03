module Matestack
  module Ui
    module VueJs
      module Components
        class Action < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-action'

          def response
            a attributes do
              yield
            end
          end

          def attributes
            {
              href: options[:path],
              '@click.prevent': 'perform',
            }
          end

          def config
            {}.tap do |conf|
              conf[:action_path] = options[:path]
              conf[:method] = options[:method]
              conf[:success] = options[:success]
              conf[:failure] = options[:failure]
              conf[:notify] = true if options[:notify].nil?
              conf[:confirm] = options[:confirm]
              conf[:confirm_text] = options[:confirm].try(:[], :text) || 'Are you sure?'
              conf[:data] = options[:data]
            end
          end

        end
      end
    end
  end
end