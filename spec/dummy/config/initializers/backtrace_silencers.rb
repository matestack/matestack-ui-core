# Be sure to restart your server when you modify this file.

# https://api.rubyonrails.org/classes/ActiveSupport/BacktraceCleaner.html
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/backtrace_cleaner.rb

# Show only stacktrace of matestack or the dummy app and not the other gems
Rails.backtrace_cleaner.remove_silencers!
Rails.backtrace_cleaner.add_silencer { |line| line.include? "/usr/local/bundle/gems" }

# Remove docker-path prefix "/app/" from paths to allow advanced terminal features
# like iTerm's "semantic history" which would be broken by the docker path.
Rails.backtrace_cleaner.remove_filters!
Rails.backtrace_cleaner.add_filter { |line| line.gsub(/^\/app\//, '') }
