# The main renderer that is usually called to determine how to perform rendering
module Matestack::Ui::Core::Rendering::MainRenderer
  module_function

  EMPTY_JSON = "{}"

  # Instead of rendering without an app class, we always have an "empty" app class
  # to fall back to
  DEFAULT_APP_CLASS = Matestack::Ui::Core::App::App

  def render(controller_instance, page_class, options)
    app_class = resolve_app_class(controller_instance, options)

    params = controller_instance.params

    context = create_context_hash(controller_instance)

    if params[:only_page]
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      render_matestack_object(controller_instance, page_instance)
    elsif (component_key = params[:component_key])
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      render_component(component_key, page_instance, controller_instance, context)
    # elsif (component_name = params[:component_key])
    #   render_isolated_component(component_name, params.fetch(:component_args, EMPTY_JSON), controller_instance, context)
    # TODO: right now this still goes through the URL of the page, hijacks it without caring
    # about the page or app at all. If the component is truly isolated then I'd recommend
    # maybe mounting a URL from the engine side where these requests go for rendering
    # isolated components.
    else
      if app_class == false
        page_instance = page_class.new(controller_instance: controller_instance, context: context)
        render_matestack_object(controller_instance, page_instance, layout: true)
      else
        app_instance = app_class.new(page_class, controller_instance, context)
        render_matestack_object(controller_instance, app_instance, layout: true)
      end
    end
  end

  def create_context_hash(controller_instance)
    {
      view_context: controller_instance.view_context,
      params: controller_instance.params,
      request: controller_instance.request
    }
  end

  def render_matestack_object(controller_instance, object, opts = {}, render_method = :show)
    object.prepare
    object.response
    rendering_options = {html: object.call(render_method)}.merge!(opts)
    controller_instance.render rendering_options
  end

  def render_component(component_key, page_instance, controller_instance, context)
    matched_component = nil

    page_instance.matestack_set_skip_defer(false)

    page_instance.prepare
    page_instance.response

    matched_component = dig_for_component(component_key, page_instance)

    unless matched_component.nil?
      render_matestack_object(controller_instance, matched_component, {}, :render_content)
    else
      # some 404 probably
      raise Exception, "Async component with id #{component_key} could not be found while rerendering."
    end
  rescue Exception => e
     Rails.logger.warn e
     render json: {}, status: :not_found
  end

  def dig_for_component component_key, component_instance
    matched_component = nil

    component_instance.children.each do |child|
      if child.respond_to?(:get_component_key)
        if child.get_component_key == component_key
          matched_component = child
        end
      end
    end

    if matched_component.nil?
      component_instance.children.each do |child|
        if child.children.any?
          matched_component = dig_for_component(component_key, child)
          break if !matched_component.nil?
        end
      end
      return matched_component
    else
      return matched_component
    end

  end

  # TODO: too many arguments maybe get some of them together?
  # def render_isolated_component(component_name, jsoned_args, controller_instance, context)
  #   component_class = resolve_isolated_component(component_name)
  #
  #   if component_class
  #     args = JSON.parse(jsoned_args)
  #     args[:context] = context
  #     # TODO: add context/controller_instance etc.
  #     component_instance = component_class.new(args)
  #     if component_instance.authorized?
  #       render_matestack_object(controller_instance, component_instance)
  #     else
  #       # some 4xx? 404?
  #       raise "not authorized"
  #     end
  #   else
  #     # some 404 probably
  #     raise "component not found"
  #   end
  # end

  def resolve_component(name)
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

  # def resolve_isolated_component(name)
  #   constant = const_get(name)
  #   # change to specific AsyncComponent parent class
  #   if constant < Matestack::Ui::Core::Async::Async
  #     constant
  #   else
  #     nil
  #   end
  # rescue NameError
  #   nil
  # end


  def resolve_app_class(controller_instance, options)
    app_class = DEFAULT_APP_CLASS

    controller_level_app_class = controller_instance.class.get_matestack_app_class
    action_level_app_class = options[:matestack_app]

    if !controller_level_app_class.nil?
      if controller_level_app_class == false
        app_class = false
      else
        if controller_level_app_class.is_a?(Class) && (controller_level_app_class < Matestack::Ui::App)
          app_class = controller_level_app_class
        else
          raise "#{controller_level_app_class} is not a valid Matestack::Ui::App class"
        end
      end
    end
    if !action_level_app_class.nil?
      if action_level_app_class == false
        app_class = false
      else
        matestack_app_class = action_level_app_class
        if action_level_app_class.is_a?(Class) && (action_level_app_class < Matestack::Ui::App)
          app_class = action_level_app_class
        else
          raise "#{action_level_app_class} is not a valid Matestack::Ui::App class"
        end
      end
    end

    return app_class
  end

end
