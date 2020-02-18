module Matestack::Ui::Core::Component
  class Dynamic < Base
    def show
      render :dynamic_without_rerender
    end

    def dynamic_tag_attributes
      attrs = {
        "is": @component_class,
        "ref": component_id,
        ":params":  @url_params.to_json,
        ":component-config": @component_config.to_json,
        "inline-template": true,
      }
      attrs.merge!(options[:attributes]) unless options[:attributes].nil?
      return attrs
   end
  end
end
