# The main renderer that is usually called to determine how to perform rendering
module Matestack::Ui::Core::Rendering::MainRenderer
  module_function

  EMPTY_JSON = "{}"

  def render(controller_instance, page_class, options)
    app_class = get_app_class(page_class)

    params = controller_instance.params

    context = create_context_hash(controller_instance)

    # My initial  thinking was to have different renderer classes for these, but with rendering this easy
    # they're probably not needed
    if params[:only_page]
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      render_matestack_object(controller_instance, page_instance)
    # TODO: right now this still goes through the URL of the page, hijacks it without caring
    # about the page or app at all. If the component is truly isolated then I'd recommend
    # maybe mounting a URL from the engine side where these requests go for rendering
    # isolated components.
    elsif (component_name = params[:component_key])
      render_isolated_component(component_name, params.fetch(:component_args, EMPTY_JSON), controller_instance, context)
    else
      app_instance = app_class.new(page_class, controller_instance, context)
      render_matestack_object(controller_instance, app_instance, layout: true)
    end
  end

  def create_context_hash(controller_instance)
    {
      view_context: controller_instance.view_context,
      params: controller_instance.params,
      request: controller_instance.request
    }
  end

  def render_matestack_object(controller_instance, object, opts = {})
    object.prepare
    object.response
    rendering_options = {html: object.show}.merge!(opts)
    controller_instance.render rendering_options
  end

  # TODO: too many arguments maybe get some of them together?
  def render_isolated_component(component_name, jsoned_args, controller_instance, context)
    component_class = resolve_isolated_component(component_name)

    if component_class
      args = JSON.parse(jsoned_args)
      args[:context] = context
      # TODO: add context/controller_instance etc.
      component_instance = component_class.new(args)
      if component_instance.authorized?
        render_matestack_object(controller_instance, component_instance)
      else
        # some 4xx? 404?
        raise "not authorized"
      end
    else
      # some 404 probably
      raise "component not found"
    end
  end

  def resolve_isolated_component(name)
    constant = const_get(name)
    # change to specific AsyncComponent parent class
    if constant < Matestack::Ui::Core::Async::Async
      constant
    else
      nil
    end
  rescue NameError
    nil
  end

  # Instead of rendering without an app class, we always have an "empty" app class
  # to fall back to
  DEFAULT_APP_CLASS = Matestack::Ui::Core::App::App

  # See #382 for how this shall change in the future
  # TLDR; we should get it more or less explicitly from the controller
  def get_app_class(page_class)
    class_name = page_class.name
    name_parts = class_name.split("::")

    return DEFAULT_APP_CLASS if name_parts.count <= 2

    app_name = "#{name_parts[1]}"
    begin
      app_class = Apps.const_get(app_name)
      if app_class.is_a?(Class)
        app_class
      else
        require_dependency "apps/#{app_name.underscore}"
        app_class = Apps.const_get(app_name)
        if app_class.is_a?(Class)
          app_class
        else
          DEFAULT_APP_CLASS
        end
      end
    rescue
      DEFAULT_APP_CLASS
    end
  end
end
