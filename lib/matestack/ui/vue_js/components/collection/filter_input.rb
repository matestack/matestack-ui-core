module Matestack
  module Ui
    module VueJs
      module Components
        module Collection
          class FilterInput < Matestack::Ui::Component

            required :key, :type
            optional :placeholder

            def response
              input attributes
            end

            def attributes
              {
                "v-model#{'.number' if ctx.type == :number}": input_key,
                type: ctx.type,
                # id: component_id,
                "@keyup.enter": "submitFilter()",
                ref: "filter.#{attr_key}",
                placeholder: ctx.placeholder
              }.merge(options)
            end

            def input_key
              'filter["' + ctx.key.to_s + '"]'
            end

            def attr_key
              ctx.key.to_s
            end

          end
        end
      end
    end
  end
end
