module Matestack
  module Ui
    module VueJs
      module Components
        class App < Matestack::Ui::VueJs::Vue

          optional :id

          vue_name "matestack-ui-core-app"

          # def create_children &block
          #   div id: context.id || "matestack-ui" do
          #     vue_component do
          #       self.response &block
          #     end
          #   end
          # end

          def response
            div class: 'matestack-app-wrapper' do
              yield
            end
          end

          #
          # # def create_children &block
          # #   self.app_wrapper do
          # #     self.response &block
          # #   end
          # # end
          #
          # def app_wrapper
          #   vue_component do
          #     div class: 'matestack-app-wrapper' do
          #       yield
          #     end
          #   end
          # end

          def loading_state_element
          end
        end
      end
    end
  end
end
