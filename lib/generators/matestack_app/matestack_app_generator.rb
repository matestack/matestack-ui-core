class MatestackAppGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :all_inclusive, type: :boolean, default: false

  def create_matestack_app

    generator_path = "app/matestack/apps/#{file_name}.rb"

    template 'matestack_app.erb', generator_path

    if options[:all_inclusive] == true
      controller_path = "app/controllers/#{file_name}_controller.rb"
      template 'matestack_app_controller.erb', controller_path

      route %{get '#{file_name}/example_page', to: '#{file_name}\#example_page'}

      generate "matestack_page example_page --app_name #{file_name} --called_by_app_generator=true"

      puts "You can visit your new matestack apps' example page under http://localhost:3000/#{file_name}/example_page"

    end

  end

end
