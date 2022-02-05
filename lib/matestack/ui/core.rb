base_path = 'matestack/ui/core'
require "#{base_path}/version"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.tag = "matestack-ui-core"
loader.setup

module Matestack::Ui::Core
end



# VueJs Components
vue_js_base_path = 'matestack/ui/vue_js'
module Matestack
  module Ui
    module VueJs

    end
  end
end

