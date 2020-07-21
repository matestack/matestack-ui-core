module Matestack::Ui::Core::HtmlAttributes

  # contains all passed options
  attr_accessor :html_attributes

  def extract_html_attributes(options)
    self.html_attributes = options.except(
      :context,
      :included_config,
      :matestack_context,
      :children,
      :url_params
    )
  end

end