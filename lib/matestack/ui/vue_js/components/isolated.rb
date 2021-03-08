module Matestack
  module Ui
    module VueJs
      module Components
        class Isolated < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-isolate'

          internal :defer, :init_on, :public_options, :rerender_on, :rerender_delay

          def create_children
            # content only should be rendered if param :component_class is present
            if params[:component_class].present?
              if authorized?
                self.response
              end
            else
              self.isolated do
                self.response
              end
            end
          end

          def isolated
            Matestack::Ui::Core::Base.new(:component, component_attributes) do
              div class: 'matestack-isolated-component-container', 'v-bind:class': '{ loading: loading === true }' do
                unless internal_context.defer || internal_context.init_on
                  div class: 'matestack-isolated-component-wrapper', 'v-if': 'isolatedTemplate == null', 'v-bind:class': '{ loading: loading === true }' do
                    yield
                  end
                end
                div class: 'matestack-isolated-component-wrapper', 'v-if': 'isolatedTemplate != null', 'v-bind:class': '{ loading: loading === true }' do
                  Matestack::Ui::Core::Base.new('v-runtime-template', ':template': 'isolatedTemplate')
                end
              end
            end
          end

          def config
            {
              component_class: self.class.name,
              public_options: internal_context.public_options,
              defer: internal_context.defer,
              rerender_on: internal_context.rerender_on,
              rerender_delay: internal_context.rerender_delay,
              init_on: internal_context.init_on,
            }
          end

          def authorized?
            raise "authorized needs to be implemented by #{self.class}"
          end

        end
      end
    end
  end
end