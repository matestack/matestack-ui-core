module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class FieldsForAddItem < Matestack::Ui::VueJs::Vue
            vue_name 'matestack-ui-core-form-fields-for-add-item'

            required :key
            required :prototype

            attr_accessor :prototype_template_json

            def create_children(&block)
              # first render prototype_template_json
              self.prototype_template_json = context.prototype.call().to_json
              # delete from children in order not to render the prototype
              self.children.shift
              super
            end

            def response
              div id: "prototype-template-for-#{context.key}", "v-pre": true, data: { ":template":  self.prototype_template_json }
              Matestack::Ui::Core::Base.new('matestack-ui-core-runtime-render', ':template': "vc.parentNestedFormRuntimeTemplates['#{context.key}']", ':vc': 'vc')
              a class: 'matestack-ui-core-form-fields-for-add-item', "@click.prevent": "vc.addItem('#{context.key}')" do
                yield if block_given?
              end
            end

          end
        end
      end
    end
  end
end
