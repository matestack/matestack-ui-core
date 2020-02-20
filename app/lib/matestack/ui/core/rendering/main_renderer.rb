# The main renderer that is usually called to determine how to perform rendering
module Matestack::Ui::Core::Rendering::MainRenderer
  module_function

  # Instead of rendering without an app class, we always have an "empty" app class
  # to fall back to
  DEFAULT_APP_CLASS = Matestack::Ui::Core::App::App

  def render(controller_instance, page_class, options, params)
    app_class = get_app_class(page_class)

    # controller related data
    view_context = controller_instance.view_context
    params = controller_instance.params
    request = controller_instance.request

    app_instance = app_class.new(page_class, controller_instance)

    # Render all things
    controller_instance.render html: app_instance.show, layout: true
  end

  def other_render_stuff
    unless params[:component_key].blank?
      # TODO: why is this plain and not html?
      controller_instance.render plain: render_component(page_class, params[:component_key])
      return
    end
    if params[:only_page]
      controller_instance.render html: render_page(controller_instance, page_class, true)
    else
      controller_instance.render html: render_page(controller_instance, page_class), layout: true
    end

    # render mode dispatch extracted from Page, actual dispatch should happen here now

    # TODO this is likely broken if someone named a component Isolate or name space
    return resolve_isolated_component(component_key) if !component_key.nil? && component_key.include?("isolate")
    render_mode = nil
    render_mode = :only_page if only_page == true
    render_mode = :render_page_with_app if !@app_class.nil? && only_page == false
    render_mode = :only_page if @app_class.nil? && only_page == false
    render_mode = :render_component if !component_key.nil?

    case render_mode

    when :only_page
      render :page
    when :render_page_with_app
      concept(@app_class).call(:show, @page_id, @nodes)
    when :render_component
      begin
        # TODO when is this called and make it good again
        render_child_component component_key
      rescue => e
        raise "Component '#{component_key}' could not be resolved, because of #{e},\n#{e.backtrace.join("\n")}"
      end
    end
  end

  def render_page(controller_instance, page_class, only_page=false)
    page_class.new(nil, context: {
      params: params,
      request: request,
      view_context: view_context
    }, controller_instance: controller_instance).call(:show, nil, only_page)
  end

  def render_component(controller_instance, page_class, component_key)
    page_class.new(nil, context: {
      params: params,
      request: request
    }, controller_instance: controller_instance).call(:show, component_key)
  end

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
