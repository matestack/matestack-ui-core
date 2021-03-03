module Matestack
  module Ui
    module VueJs
      module Components
        class Isolated < Matestack::Ui::VueJs::Vue
          vue_name 'matestack-ui-core-isolate'

          attr_accessor :defer
          attr_accessor :init_on
          attr_accessor :public_options
          
          def initialize(html_tag = nil, text = nil, options = {}, &block)
            extract_options(text, options)
            self.public_options = self.options[:public_options]
            super
            self.defer = self.options[:defer]
            self.init_on = self.options[:init_on]
          end

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
                unless self.defer || self.init_on
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
              public_options: options[:public_options],
              defer: options[:defer],
              rerender_on: options[:rerender_on],
              rerender_delay: options[:rerender_delay],
              init_on: options[:init_on],
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