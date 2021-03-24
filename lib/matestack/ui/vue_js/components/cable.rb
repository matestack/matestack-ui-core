module Matestack
  module Ui
    module VueJs
      module Components
        class Cable < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-cable'

          attr_accessor :block_content

          required :id
          optional :append_on, :prepend_on, :delete_on, :update_on, :replace_on

          def create_children(&block)
            # first render block content
            self.block_content = content(&block).render_content if block_given?
            super
          end

          def content(&block)
            Matestack::Ui::Core::Base.new(:without_parent, nil, nil) do
              div(class: 'matestack-cable-component-root', id: ctx.id, &block)
            end
          end

          def component_attributes
            super.merge('v-bind:initial-template': "#{self.block_content.to_json}")
          end

          def response
            div container_attributes do
              div wrapper_attributes do
                Matestack::Ui::Core::Base.new('v-runtime-template', ':template': 'cableTemplate')
              end
            end
          end

          def container_attributes
            {
              class: 'matestack-cable-component-container',
              'v-bind:class': '{ loading: loading === true }'
            }
          end

          def wrapper_attributes
            {
              class: 'matestack-cable-component-wrapper',
              'v-if': 'cableTemplate != null', 
              'v-bind:class': '{ loading: loading === true }'
            }
          end

          def config
            {
              id: ctx.id,
              component_key: ctx.id,
              # events
              append_on: ctx.append_on,
              prepend_on: ctx.prepend_on,
              delete_on: ctx.delete_on,
              update_on: ctx.update_on,
              replace_on: ctx.replace_on,
            }
          end

        end
      end
    end
  end
end