module Matestack::Ui::Core::Page

  # TODO: Most of the functionality is shared but some initialize stuff a page probably doesn't need
  class Page < Matestack::Ui::Core::Component::Base
    include ActionView::Helpers::TranslationHelper

    def initialize(options = {})
      super(nil, options)
      copy_controller_instance_variables(options.fetch(:controller_instance))
      generate_page_name
    end

    # This is basically the middle component in charge of rendering here,
    # I believe we need to reverse this so that we first go through the
    # App, then to the page and then to the components.
    # Perhaps through a renderer component.
    def show
      render :page
    end

    def page_id
      @custom_page_id ||= @page_id
    end


    private

      def copy_controller_instance_variables(controller)
        controller.instance_variables.each do |controller_instance_var_key|
          unless controller_instance_var_key.to_s.start_with?("@_")
            # TODO BUG: We might override our own instance variables here.
            # Solution 1: Check against own instance variables and don't do
            # Solution 2: Create own context object and don't pollute instance variables
            # Solution 3: Prefix own instance varibale @_mate or so to circumvent conflicts
            self.instance_variable_set(controller_instance_var_key, controller.instance_variable_get(controller_instance_var_key))
          end
        end
      end

      # TODO: This page_id part won't work when pages aren't scoped by app
      # anymore/needs to respect app
      def generate_page_name
        name_parts = self.class.name.split("::").map { |name| name.underscore }
        @page_id = name_parts.join("_")
      end
  end
end
