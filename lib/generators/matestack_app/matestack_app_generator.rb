class MatestackAppGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :controller, type: :boolean, default: false

  def create_matestack_app

    generator_path = "app/matestack/apps/#{file_name}.rb"

    template 'matestack_app.erb', generator_path

    create_matestack_app_controller if options[:controller] == true 

  end

  def create_matestack_app_controller
    controller_path = "app/controllers/#{file_name}_controller.rb"
    template 'matestack_app_controller.erb', controller_path
  end

end
