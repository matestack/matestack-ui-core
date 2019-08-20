class MatestackPageGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :app_name, type: :string, required: true
  class_option :namespace, type: :string
  class_option :controller_action, type: :string
  class_option :called_by_app_generator, type: :boolean, default: false

  def create_matestack_page
    @app_name = options[:app_name]
    @namespace = options[:namespace]

    if options[:controller_action].nil?
      @controller_action = "#{@app_name}\##{file_name}"
    else
      @controller_action = options[:controller_action]
    end

    matestack_page_dir_path = "app/matestack/pages"
    matestack_page_dir_path << "/#{@app_name}" unless @app_name.nil?
    matestack_page_dir_path << "/#{@namespace}" unless @namespace.nil?

    generator_path = matestack_page_dir_path + "/#{file_name}.rb"

    template "matestack_page.erb", generator_path

    unless options[:called_by_app_generator]
      route %{get '#{@app_name}/#{@namespace}/#{file_name}', to: '#{@controller_action}'} unless @namespace.nil?
      route %{get '#{@app_name}/#{file_name}', to: '#{@controller_action}'} if @namespace.nil?
      puts "Page created! Make sure to add "
      puts ""
      puts "def #{file_name}"
      puts "  responder_for(Pages::#{@app_name.camelize}::#{@namespace.camelize}::#{file_name.camelize})" unless @namespace.nil?
      puts "  responder_for(Pages::#{@app_name.camelize}::#{file_name.camelize})" if @namespace.nil?
      puts "end"
      puts ""
      puts "to the desired controller!"
    end

  end
end
