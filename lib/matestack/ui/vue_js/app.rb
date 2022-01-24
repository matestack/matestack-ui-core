module Matestack
  module Ui
    module VueJs
      class App < Matestack::Ui::Core::App

        include Matestack::Ui::VueJs::Utils

        vue_name "matestack-ui-core-app"

        def create_children &block
          self.app_wrapper do
            self.response &block
          end
        end

        def app_wrapper(&block)
          vue_component do
            div(class: 'matestack-app-wrapper', &block)
          end
        end

        def loading_state_element
        end

      end
    end
  end
end
