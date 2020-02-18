module Matestack::Ui::Core::HasViewContext
  def initialize(*args)
    # TODO: check if it's ok to have this semi optional
    super
    @view_context = @options.dig(:context, :view_context)
  end

  def method_missing(*args, &block)
    if @view_context.respond_to? args.first
      @view_context.send(*args, &block)
    else
      super
    end
  end
end
