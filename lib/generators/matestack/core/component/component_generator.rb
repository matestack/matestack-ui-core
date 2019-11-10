# frozen_string_literal: true

module Matestack
  module Core
    module Generators
      class ComponentGenerator < Rails::Generators::NamedBase
        source_root File.expand_path('templates', __dir__)

        def create_core_component
          template 'app/concepts/matestack/ui/core/%file_name%/%file_name%.haml'
          template 'app/concepts/matestack/ui/core/%file_name%/%file_name%.rb'
          template 'spec/usage/components/%file_name%_spec.rb'
          template 'docs/components/%file_name%.md'

          inject_into_file 'docs/components/README.md', before: "\n## Dynamic Core Components\n" do <<~RUBY
            - [#{file_name.underscore}](/docs/components/#{file_name.underscore}.md)
          RUBY
          end
        end
      end
    end
  end
end
