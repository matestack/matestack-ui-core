class MatestackPageGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :app_name, type: :string, required: true

  class_option :controller_action, type: :string

  def create_matestack_page
    @app_name = app_name

    if options[:controller_action].nil?
      @controller_action = "#{@app_name}\##{file_name}"
    else
      @controller_action = options[:controller_action]
    end

    matestack_page_dir_path = "app/matestack/pages/#{@app_name}"

    generator_path = matestack_page_dir_path + "/#{file_name}.rb"

    template "matestack_page.erb", generator_path

    route %{get '#{@app_name}/#{file_name}', to: '#{@controller_action}'}

    puts "Make sure to add responder_for(Pages::#{@app_name.camelize}::#{file_name.camelize}) to #{@controller_action}"

    # todo
    # swap app and page input order
    # - scaffold failing rspec test cases per default via options[:rspec]
    # - check if spec/ folder exists in host system => if not, puts 'rspec test suite not found'
    # talk to jonas: do pages always belong to apps?
    # - if yes: generate corresponding app if it does not exist
    # - if yes: invoce `generate matestack_app` with ARGS => should create controller_action and view aswell
    # generate "scaffold", "forums title:string description:text"
  end
end
