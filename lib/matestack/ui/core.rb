base_path = 'matestack/ui/core'
require "#{base_path}/version"

module Matestack
  module Ui
    module Core
      
    end
  end
end

require "#{base_path}/context"
require "#{base_path}/properties"
require "#{base_path}/base"
require "#{base_path}/component_registry"
require "#{base_path}/component"
require "#{base_path}/page"
require "#{base_path}/app"
require "#{base_path}/helper"

# require abbreveations for apps, pages and components
require "matestack/ui/app"
require "matestack/ui/page"
require "matestack/ui/component"

# VueJs Components
vue_js_base_path = 'matestack/ui/vue_js'
module Matestack
  module Ui
    module VueJs

    end
  end
end

require "#{vue_js_base_path}/vue"
require "#{vue_js_base_path}/components/toggle"
require "#{vue_js_base_path}/components/onclick"
require "#{vue_js_base_path}/components/transition"
require "#{vue_js_base_path}/components/async"
require "#{vue_js_base_path}/registry"
