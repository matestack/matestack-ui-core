# Handles the default rendering mechanism
#
# Not really compatible with the new flexible naming schemes
module Matestack::Ui::Core::Rendering::DefaultRendererClassDeterminer
  module_function

  def determine_class(controller_path, action_name)
    possible_default_render_matestack_page_class_names(controller_path, action_name).each do |class_name|
      begin
        return matestack_class = class_name.constantize
      rescue NameError
      end
    end
    return nil
  end

  def possible_default_render_matestack_page_class_names(controller_path, action_name)
    possible_default_render_matestack_page_paths(controller_path, action_name).collect { |page_path|
      page_path.split("/").collect { |str| str.camelcase }.join("::")
    }
  end

  def possible_default_render_matestack_page_paths(controller_path, action_name)
    paths = []
    paths << "pages/#{controller_path}/#{action_name}"
    paths << "pages/#{controller_path}" if action_name == "index"
    paths << "pages/#{controller_path.singularize}" if action_name == "show"
    paths << "#{controller_path}/#{action_name}_page"
    paths << "#{controller_path}_page" if action_name == "index"
    paths << "#{controller_path.singularize}_page" if action_name == "show"
    paths
  end
end
