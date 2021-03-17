module Matestack
  module Ui
    module VueJs
      module Components
        class Isolated < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-isolate'

          optional :defer, :init_on, :public_options, :rerender_on, :rerender_delay

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
                unless ctx.defer || ctx.init_on
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
              public_options: ctx.public_options,
              defer: ctx.defer,
              rerender_on: ctx.rerender_on,
              rerender_delay: ctx.rerender_delay,
              init_on: ctx.init_on,
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