module Matestack
  module Ui
    module VueJs
      module Components
        class Isolated < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-isolate'

          optional :defer, :init_on, :public_options, :rerender_on, :rerender_delay

          def initialize(html_tag = nil, text = nil, options = {}, &block)
            extract_options(text, options)
            only_public_options!
            isolated_parent = Matestack::Ui::Core::Context.isolated_parent
            Matestack::Ui::Core::Context.isolated_parent = self
            super(html_tag, text, options, &block)
            Matestack::Ui::Core::Context.isolated_parent = isolated_parent
          end

          def create_children
            # content only should be rendered if param :component_class is present
            warn "[WARNING] '#{self.class}' was accessed but not authorized" unless authorized?
            if params[:component_class].present?
              self.response if authorized?
            else
              self.isolated do
                self.response if authorized?
              end
            end
          end

          def isolated
            Matestack::Ui::Core::Base.new(:component, component_attributes) do
              div class: 'matestack-isolated-component-container', 'v-bind:class': '{ loading: loading === true }' do
                if self.respond_to? :loading_state_element
                  div class: 'loading-state-element-wrapper', 'v-bind:class': '{ loading: loading === true }' do
                    loading_state_element
                  end
                end
                unless ctx.defer || ctx.init_on
                  div class: 'matestack-isolated-component-wrapper', 'v-if': 'isolatedTemplate == null', 'v-bind:class': '{ loading: loading === true }' do
                    div class: 'matestack-isolated-component-root' do
                      yield
                    end
                  end
                end
                div class: 'matestack-isolated-component-wrapper', 'v-if': 'isolatedTemplate != null', 'v-bind:class': '{ loading: loading === true }' do
                  div class: 'matestack-isolated-component-root' do
                    Matestack::Ui::Core::Base.new('v-runtime-template', ':template': 'isolatedTemplate')
                  end
                end
              end
            end
          end

          def vue_props
            {
              component_class: self.class.name,
              public_options: ctx.public_options,
              defer: ctx.defer,
              rerender_on: ctx.rerender_on,
              rerender_delay: ctx.rerender_delay,
              init_on: ctx.init_on,
            }
          end

          def public_options
            ctx.public_options || {}
          end

          def authorized?
            raise "'authorized?' needs to be implemented by '#{self.class}'"
          end

          def only_public_options!
            if self.options.except(:defer, :init_on, :public_options, :rerender_on, :rerender_delay).keys.any?
              error_message = "isolated components can only take params in a public_options hash, which will be exposed to the client side in order to perform an async request with these params."
              error_message << " Check your usages of '#{self.class}' components"
              raise error_message
            end
          end

        end
      end
    end
  end
end