module Matestack::Ui::Core::HasViewContext
  def initialize(model = nil, options = {})
    @view_context = options[:context][:view_context]
    super
  end

  def method_missing(*args, &block)
    if @view_context.respond_to? args.first
      @view_context.send(*args, &block)
    else
      super
    end
  end
end
