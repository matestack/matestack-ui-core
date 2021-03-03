module Matestack
  module Ui
    module Core
      class Page < Base
        
        def initialize(options = {})
          super(nil, nil, options)
        end
        
        def create_children
          self.page do
            self.response
          end
        end
        
        def page
          if params[:only_page]
            div class: 'matestack-page-root' do
              yield
            end
          else
            Base.new(:component, component_attributes) do
              div class: 'matestack-page-container', 'v-bind:class': '{ "loading": loading === true }'  do
                div class: 'matestack-page-wrapper', 'v-bind:class': '{ "loading": loading === true }' do
                  div 'v-if': 'asyncPageTemplate == null' do
                    div class: 'matestack-page-root' do
                      yield
                    end
                  end
                  div 'v-if': 'asyncPageTemplate != null' do
                    div class: 'matestack-page-root' do
                      Base.new('v-runtime-template', ':template': 'asyncPageTemplate')
                    end
                  end
                end
              end
            end
          end
        end
        
        def component_attributes
          {
            is: 'matestack-ui-core-page-content',
            ref: 'some-id',
            ':params': params.to_json,
            ':component-config': {
              show_on: 'a-event',
              hide_on: 'test'
            }.to_json,
            'inline-template': true
          }
        end
        
      end
    end
  end
end