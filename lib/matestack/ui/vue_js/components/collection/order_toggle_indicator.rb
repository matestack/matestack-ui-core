module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class OrderToggleIndicator < Matestack::Ui::Component

            required :key, :asc, :desc
            optional :default

            def response
              span do
                span "v-if": "vc.ordering['#{ctx.key}'] === undefined" do
                  plain ctx.default
                end
                unescaped "{{
                  vc.orderIndicator(
                    '#{ctx.key}',
                    { asc: '#{ctx.asc}', desc: '#{ctx.desc}'}
                  )
                }}"
              end
            end

          end
        end
      end
    end
  end
end
