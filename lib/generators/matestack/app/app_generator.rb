# frozen_string_literal: true

module Matestack
  module Generators
    class AppGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      class_option :all_inclusive, type: :boolean, default: false

      def create_app
        template 'app/matestack/apps/%file_name%.rb.tt'

        if options[:all_inclusive] == true
          template 'app/controllers/%file_name%_controller.rb'

          route %{get '#{file_name}/example_page', to: '#{file_name}\#example_page'}

          generate "matestack:page example_page --app_name #{file_name} --called_by_app_generator=true"

          puts "You can visit your new matestack apps' example page under http://localhost:3000/#{file_name}/example_page"
        end
      end
    end
  end
end
