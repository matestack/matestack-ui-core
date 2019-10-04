class MatestackComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :dynamic, type: :boolean, default: false
  class_option :scss, type: :boolean, default: false
  class_option :haml, type: :boolean, default: false
  class_option :namespace, type: :string

  def create_matestack_component
    @dynamic = options[:dynamic]
    @namespace = options[:namespace]

    # Future: Check for matestack-compatible namespacing!

    to_be_created_files = ['.rb']
    to_be_created_files << '.js' if options[:dynamic]
    to_be_created_files << '.scss' if options[:scss]
    to_be_created_files << '.haml' if options[:haml]

    matestack_component_dir_path = "app/matestack/components/"
    matestack_component_dir_path << "#{@namespace}/" unless @namespace.nil?

    to_be_created_files.each do |file|
      generator_path = matestack_component_dir_path + "/#{file_name}#{file}"
      template "matestack_component#{file}.erb", generator_path
    end

  end

end
