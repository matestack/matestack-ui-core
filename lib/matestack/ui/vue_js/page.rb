module Matestack
  module Ui
    module VueJs
      class Page < Matestack::Ui::Core::Page

        include Matestack::Ui::VueJs::Utils

        vue_name "matestack-ui-core-page"

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
            vue_component do
              div class: 'matestack-page-container', 'v-bind:class': '{ "loading": vc.loading === true }'  do
                if Matestack::Ui::Core::Context.app.respond_to? :loading_state_element
                  div class: 'loading-state-element-wrapper', 'v-bind:class': '{ "loading": vc.loading === true }'  do
                    Matestack::Ui::Core::Context.app.loading_state_element
                  end
                end
                div class: 'matestack-page-wrapper', 'v-bind:class': '{ "loading": vc.loading === true }' do
                  div 'v-if': 'vc.asyncPageTemplate == null' do
                    div class: 'matestack-page-root' do
                      yield
                    end
                  end
                  div 'v-if': 'vc.asyncPageTemplate != null' do
                    div class: 'matestack-page-root' do
                      Matestack::Ui::Core::Base.new('matestack-ui-core-runtime-render', ':template': 'vc.asyncPageTemplate', ':vc': 'vc', ':vue-component': 'vueComponent')
                    end
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
