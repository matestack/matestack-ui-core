module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class Content < Matestack::Ui::VueJs::Vue
            vue_name 'matestack-ui-core-collection-content'

            required :id
            optional :init_limit, :filtered_count, :base_count

            def response
              div class: "matestack-ui-core-collection-content" do
                yield
              end
            end

            def vue_props
              {
                id: ctx.id,
                init_limit: ctx.init_limit,
                filtered_count: ctx.filtered_count,
                base_count: ctx.base_count
              }
            end

          end
        end
      end
    end
  end
end
