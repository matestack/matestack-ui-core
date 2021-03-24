begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Matestack::Ui::Core'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load 'rails/tasks/engine.rake'

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'

require 'rake/testtask'

# Rake::TestTask.new(:test) do |t|
#   t.libs << 'test'
#   t.pattern = 'test/**/*_test.rb'
#   t.verbose = false
# end
#
# task default: :test

task :webpack => 'webpack:build'

namespace :webpack do
  task :build => ['build:development', 'build:production']

  namespace :build do
    task :development => 'yarn:install' do
      Bundler.with_unbundled_env do
        sh "cd builder && bin/webpack"
      end
    end
    task :production => 'yarn:install' do
      Bundler.with_unbundled_env do
        sh "cd builder && bin/rake webpacker:compile"
      end
    end
  end

  task :watch => 'yarn:install' do
    Bundler.with_unbundled_env do
      sh "cd builder && bin/webpack --watch"
    end
  end

  namespace :yarn do
    task :install do
      sh "yarn install && cd builder && yarn install"
    end
  end
end

