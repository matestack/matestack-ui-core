# The main renderer that is usually called to determine how to perform rendering
module Matestack::Ui::Core::Rendering::MainRenderer
  module_function

  def render(controller_instance, page_class, options)
    app_class = get_app_class(page_class)

    params = controller_instance.params

    # My initial  thinking was to have different renderer classes for these, but with rendering this easy
    # they're probably not needed
    if params[:only_page]
      page_instance = page_class.new(controller_instance: controller_instance)
      page_instance.prepare
      page_instance.response
      controller_instance.render html: page_instance.show
    # TODO: elsif looking for new component/async/isolate or what not calls goes here
    # and then has to look for the component class based on the given names
    # CAREFUL/SECURITY: Make sure not just every object can be instantiated ("common" attack vector)
    # specifically we might have to think about the scenario again where maybe a page includes
    # admin only content - a normal user shouldn't be able to just send it the AdminOnlyComponent with
    # some data and get a result back --> we probably need to give isolated components access to controller
    # instance variables or controller context as well (so that the component can check current_user or similar of the controller/request)
    else
      app_instance = app_class.new(page_class, controller_instance)
      controller_instance.render html: app_instance.show, layout: true
    end
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
