class MatestackAppGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_matestack_app

    generator_path = "app/matestack/apps/#{file_name}.rb"

    template "matestack_app.erb", generator_path

  end
end
