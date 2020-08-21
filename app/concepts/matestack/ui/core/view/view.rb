require_dependency "cell/partial"

module Matestack::Ui::Core::View
  class View < Matestack::Ui::Core::Component::Static
    include Cell::ViewModel::Partial
    view_paths << "#{::Rails.root}/app/views"

    # Only one option should be set at a time. If view is set partial will be ignored.
    optional view: { as: :view_path } # Specify a view path to render
    optional partial: { as: :partial_path } # Specifiy a partial to render

    def include_partial
      controller = @view_context.present? ? @view_context.controller : options[:matestack_context][:controller]
      if view_path
        controller.render_to_string view_path, layout: false, locals: locals
      elsif partial_path
        controller.render_to_string partial: partial_path, layout: false, locals: locals
      else  
        raise 'view or partial param missing for RailsView Component'
      end
    end

    private

    def locals
      options.except(:matestack_context, :partial, :view, :partial_path, :view_path, :included_config, :context)
    end

  end
end
