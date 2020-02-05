module Matestack::Ui::Core::HasViewContext
  def initialize(model = nil, options = {})
    @view_context = options[:context][:view_context]
    super
  end

  def method_missing(*args, &block)
    @view_context.send(*args, &block)
  end
end
