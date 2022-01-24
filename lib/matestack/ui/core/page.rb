module Matestack
  module Ui
    module Core
      class Page < Base

        def initialize(options = {})
          super(nil, nil, options)
        end

        # MOVED TO VUE MODULE
        #
        # def create_children
        #   self.page do
        #     self.response
        #   end
        # end
        #
        # def page
        #   if params[:only_page]
        #     div class: 'matestack-page-root' do
        #       yield
        #     end
        #   else
        #     Base.new(:component, component_attributes) do
        #       div class: 'matestack-page-container', 'v-bind:class': '{ "loading": vc.loading === true }'  do
        #         if Matestack::Ui::Core::Context.app.respond_to? :loading_state_element
        #           div class: 'loading-state-element-wrapper', 'v-bind:class': '{ "loading": vc.loading === true }'  do
        #             Matestack::Ui::Core::Context.app.loading_state_element
        #           end
        #         end
        #         div class: 'matestack-page-wrapper', 'v-bind:class': '{ "loading": vc.loading === true }' do
        #           div 'v-if': 'vc.asyncPageTemplate == null' do
        #             div class: 'matestack-page-root' do
        #               yield
        #             end
        #           end
        #           div 'v-if': 'vc.asyncPageTemplate != null' do
        #             div class: 'matestack-page-root' do
        #               Matestack::Ui::Core::Base.new('matestack-ui-core-runtime-render', ':template': 'vc.asyncPageTemplate', ':vc': 'vc', ':vue-component': 'vueComponent')
        #             end
        #           end
        #         end
        #       end
        #     end
        #   end
        # end
        #
        # def component_attributes
        #   {
        #     is: 'matestack-ui-core-page-content',
        #     ':params': params.to_json,
        #     'v-slot': "{ vc, vueComponent }"
        #   }
        # end

      end
    end
  end
end
