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
      # standalone page rendering, used when performing a transition
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      render_matestack_object(controller_instance, page_instance)
    elsif (params[:component_key].present? && params[:component_class].blank?)
      # async component rerendering from non isolated context
      component_key = params[:component_key]
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      render_component(component_key, page_instance, controller_instance, context)
    elsif (params[:component_class].present? && params[:component_key].blank?)
      # isolated component rendering
      component_class = params[:component_class]
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      public_options = JSON.parse(params[:public_options]).with_indifferent_access rescue nil
      render_isolated_component(component_class, page_instance, controller_instance, context, public_options)
    elsif (params[:component_class].present? && params[:component_key].present?)
      # async component rerendering from isolated context
      component_class_name = params[:component_class]
      component_key = params[:component_key]
      page_instance = page_class.new(controller_instance: controller_instance, context: context)
      if params[:public_options].present?
        public_options = JSON.parse(params[:public_options]).with_indifferent_access
      else
        public_options = nil
      end
      component_class = resolve_isolated_component(component_class_name)
      if component_class
        component_instance = component_class.new(public_options: public_options, context: context)
        if component_instance.authorized?
          render_component(component_key, component_instance, controller_instance, context)
        else
          raise "not authorized"
        end
      end
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
    object.response if object.respond_to? :response
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
  def render_isolated_component(component_class_name, page_instance, controller_instance, context, public_options = nil)
    component_class = resolve_isolated_component(component_class_name)

    if component_class
      component_instance = component_class.new(public_options: public_options, context: context)
      if component_instance.authorized?
        render_matestack_object(controller_instance, component_instance, {}, :render_isolated_content)
      else
        # some 4xx? 404?
        raise "not authorized"
      end
    else
      # some 404 probably
      raise "component not found"
    end
  end

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

  def resolve_isolated_component(name)
    constant = const_get(name)
    if constant < Matestack::Ui::Core::Isolated::Isolated
      constant
    else
      nil
    end
  rescue NameError
    nil
  end


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
