module Matestack::Ui::Core::Page

  # TODO: Most of the functionality is shared but some initialize stuff a page probably doesn't need
  class Page < Matestack::Ui::Core::Component::Static
    include ActionView::Helpers::TranslationHelper

    def initialize(options = {})
      super(nil, options)
      copy_controller_instance_variables(options.fetch(:controller_instance))
    end

    def show
      render :page
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
  end
end
