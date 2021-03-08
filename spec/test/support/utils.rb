module Utils

  def stripped(html_string)
    html_string
      .gsub(/>\s+</, "><")
      .gsub("\n", "")
      .gsub(/\s+/, "") # TODO: this removes all white space even button text like "Render me!" becomes "Renderme!" which I don't is as designed
      .gsub("<br>", "<br/>") # TODO Tobi get your browser together
  end

  def path_exists?(path_as_symbol)
  	Rails.application.routes.url_helpers.method_defined?(path_as_symbol)
  end

  # Because of how this is handled in tests (include Utils) this actually
  # ends up on Object so the method is available on a class level which
  # for tests allows a relatively convenient access
  def register_component(dsl_method, component_class)
    Matestack::Ui::Component.register({ dsl_method => component_class })
  end

  # even more test convenience
  def register_self_as(dsl_method)
    register_component(dsl_method, self)
  end

  def matestack_render(reset_app: true, page: MatestackWrapperPage, &block)
    page.define_method(:response, block)
    visit matestack_components_test_path 
    reset_matestack_app if reset_app
  end

  def matestack_app(&block)
    MatestackWrapperApp.define_method(:response, block)
  end

  def reset_matestack_app
    MatestackWrapperApp.define_method(:response) do |&block|
      block.call
    end
  end
end
