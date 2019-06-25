class MatestackComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :dynamic, type: :boolean, default: false
  class_option :namespace, type: :string

  def create_matestack_component
    @dynamic = options[:dynamic]
    @namespace = options[:namespace]

    to_be_created_files = ['.rb', '.haml', '.scss']
    to_be_created_files << '.js' if @dynamic == true

    matestack_component_dir_path = "app/matestack/components/"
    matestack_component_dir_path << "#{@namespace}/" unless @namespace.nil?
#    matestack_component_dir_path << "#{file_name}"

    to_be_created_files.each do |file|
      generator_path = matestack_component_dir_path + "/#{file_name}#{file}"

      template "matestack_component#{file}.erb", generator_path
    end

  end

end
