module Matestack::Ui::Core::HasViewContext
  def initialize(*args)
    super
    @view_context = @options.dig(:context, :view_context)
  end

  def method_missing(*args, &block)
    if @view_context.respond_to? args.first
      @view_context.send(*args, &block)
    else
      raise NameError, "NameError: undefined method or local variable `#{args.first}' for #{self.class.name}"
    end
  end
end