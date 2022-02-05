module Matestack
  module Ui
    autoload :App, "matestack/ui/app"  # deprecated
    autoload :Component, "matestack/ui/component"
    autoload :Layout, "matestack/ui/layout"
    autoload :Page, "matestack/ui/page"
    module Core
      autoload :Base, "matestack/ui/core/base"
      autoload :Component, "matestack/ui/core/component"
      autoload :Concerns, "matestack/ui/core/concerns"
      autoload :Context, "matestack/ui/core/context"
      autoload :Helper, "matestack/ui/core/helper"
      autoload :Layout, "matestack/ui/core/layout"
      autoload :Page, "matestack/ui/core/page"
      autoload :Properties, "matestack/ui/core/properties"
      autoload :Slots, "matestack/ui/core/slots"
      autoload :TagHelper, "matestack/ui/core/tag_helper"
      autoload :VERSION, "matestack/ui/core/version"
    end
  end
end



# VueJs Components
module Matestack
  module Ui
    autoload :VueJsComponent, "matestack/ui/vue_js_component"
    autoload :IsolatedComponent, "matestack/ui/isolated_component"
    module VueJs
      autoload :Utils, "matestack/ui/vue_js/utils"
      autoload :VueAttributes, "matestack/ui/vue_js/vue_attributes"
      autoload :Vue, "matestack/ui/vue_js/vue"
      module Components
        autoload :App, "matestack/ui/vue_js/components/app"
        autoload :PageSwitch, "matestack/ui/vue_js/components/page_switch"
        autoload :Toggle, "matestack/ui/vue_js/components/toggle"
        autoload :Onclick, "matestack/ui/vue_js/components/onclick"
        autoload :Transition, "matestack/ui/vue_js/components/transition"
        autoload :Async, "matestack/ui/vue_js/components/async"
        autoload :Action, "matestack/ui/vue_js/components/action"
        autoload :Cable, "matestack/ui/vue_js/components/cable"
        autoload :Isolated, "matestack/ui/vue_js/components/isolated"
        module Form
          autoload :Context, "matestack/ui/vue_js/components/form/context"
          autoload :Base, "matestack/ui/vue_js/components/form/base"
          autoload :Form, "matestack/ui/vue_js/components/form/form"
          autoload :NestedForm, "matestack/ui/vue_js/components/form/nested_form"
          autoload :Input, "matestack/ui/vue_js/components/form/input"
          autoload :Textarea, "matestack/ui/vue_js/components/form/textarea"
          autoload :Checkbox, "matestack/ui/vue_js/components/form/checkbox"
          autoload :Radio, "matestack/ui/vue_js/components/form/radio"
          autoload :Select, "matestack/ui/vue_js/components/form/select"
          autoload :FieldsForRemoveItem, "matestack/ui/vue_js/components/form/fields_for_remove_item"
          autoload :FieldsForAddItem, "matestack/ui/vue_js/components/form/fields_for_add_item"
        end
        module Collection
          autoload :Helper, "matestack/ui/vue_js/components/collection/helper"
          autoload :Content, "matestack/ui/vue_js/components/collection/content"
          autoload :Filter, "matestack/ui/vue_js/components/collection/filter"
          autoload :FilterReset, "matestack/ui/vue_js/components/collection/filter_reset"
          autoload :Next, "matestack/ui/vue_js/components/collection/next"
          autoload :Order, "matestack/ui/vue_js/components/collection/order"
          autoload :OrderToggle, "matestack/ui/vue_js/components/collection/order_toggle"
          autoload :OrderToggleIndicator, "matestack/ui/vue_js/components/collection/order_toggle_indicator"
          autoload :Page, "matestack/ui/vue_js/components/collection/page"
          autoload :Previous, "matestack/ui/vue_js/components/collection/previous"
        end
      end
      autoload :Components, "matestack/ui/vue_js/components"
      autoload :Initialize, "matestack/ui/vue_js/initialize"
    end
  end
end
