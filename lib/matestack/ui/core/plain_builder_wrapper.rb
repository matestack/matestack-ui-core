module Matestack
  module Ui
    module Core
      module PlainBuilderWrapper
        def initialize(ctx, builder)
          @ctx = ctx; @builder = builder
        end

        private def method_missing(method, *args, **opts, &block)
          return super unless @builder.respond_to?(method)

          @ctx.plain @builder.send(method, *args, **opts, &block)
        end
      end
    end
  end
end