class MatestackComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :dynamic, type: :boolean, default: false

  def create_matestack_component
    @dynmic = options[:dynamic]

    to_be_created_files = {
      '.rb': '.erb',
      '.haml': '.haml.erb',
      '.scss': '.scss.erb'
    }

    to_be_created_files.store('.js', '.js.erb') # if @dynamic == true

    matestack_component_dir_path = "app/matestack/components/#{file_name}"

    puts to_be_created_files

    to_be_created_files.each do |file, template_file|
      generator_path = matestack_component_dir_path + "/#{file_name}#{file}"

      template "matestack_component#{template_file}", generator_path
    end

  end

end
