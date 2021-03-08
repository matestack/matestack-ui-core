module Matestack
  module Ui
    module VueJs
      module Components
        class Async < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-async'

          internal :show_on, :hide_on, :rerender_on, :defer
          internal id: { required: true }

          # register itself as an async component in the context
          def initialize(html_tag = nil, text = nil, options = {}, &block)
            super(html_tag, text, options, &block)
            Matestack::Ui::Core::Context.async_components[self.internal_context.id] = self
          end

          def create_children(&block)
            self.response &block
          end

          def response
            if params[:component_key]
              div id: internal_context.id, class: 'matestack-async-component-root' do
                yield unless is_not_requested?
              end
            else
              vue_component do
                div class: 'matestack-async-component-container', 'v-bind:class': '{ "loading": loading === true }' do
                  div class: 'matestack-async-component-wrapper', 'v-if': 'asyncTemplate == null' do
                    div id: internal_context.id, class: 'matestack-async-component-root' do
                      yield unless is_deferred?
                    end
                  end
                  div class: 'matestack-async-component-wrapper', 'v-if': 'asyncTemplate != null' do
                    Matestack::Ui::Core::Base.new('v-runtime-template', ':template': 'asyncTemplate')
                  end
                end
              end
            end
          end

          def config
            {
              component_key: internal_context.id,
              show_on: internal_context.show_on,
              hide_on: internal_context.hide_on,
              rerender_on: internal_context.rerender_on,
              defer: internal_context.defer
            }
          end

          def is_deferred?
            internal_context.defer
          end

          def is_not_requested?
            params[:component_key].present? && params[:component_key] != internal_context.id
          end

        end
      end
    end
  end
end