module Matestack::Ui::Core::Component
  class Dynamic < Base

    def initialize(*_args)
      super
    end

    def show
      render :dynamic_without_rerender
    end

    private

    def dynamic_tag_attributes
      attrs = {
        "is": self.class.vue_js_name,
        "ref": component_id,
        ":params":  @url_params.to_json,
        ":component-config": @component_config.to_json,
        "inline-template": true,
      }
      attrs.merge!(options[:attributes]) unless options[:attributes].nil?
      attrs
    end

    class << self
      def vue_js_component_name(name)
        @vue_js_name = name.to_s
      end

      def vue_js_name
        @vue_js_name ||= self.name.split(/(?=[A-Z])/).join("-").downcase.gsub("::", "")
      end
    end
    
  end
end
