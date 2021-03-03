module Matestack
  module Ui
    module VueJs
      module Components
        class Cable < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-cable'

          attr_accessor :block_content

          # %component{dynamic_tag_attributes.merge('v-bind:initial-template': "#{render_content.to_json}")}
          #   %div{class: "matestack-cable-component-container", "v-bind:class": "{ 'loading': loading === true }"}
          #     %div{class: "matestack-cable-component-wrapper", "v-if": "cableTemplate != null", "v-bind:class": "{ 'loading': loading === true }"}
          #       %v-runtime-template{":template":"cableTemplate"}

          def create_children(&block)
            # first render block content
            self.block_content = content(&block).render_content
            super
          end

          def content(&block)
            Matestack::Ui::Core::Base.new(:without_parent, nil, nil) do
              div(class: 'matestack-cable-component-root', id: parent.options[:id], &block)
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
              id: options[:id],
              component_key: options[:id],
              # events
              append_on: options[:append_on],
              prepend_on: options[:prepend_on],
              delete_on: options[:delete_on],
              update_on: options[:update_on],
              replace_on: options[:replace_on],
            }
          end

        end
      end
    end
  end
end