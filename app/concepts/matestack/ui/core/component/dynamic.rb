module Matestack::Ui::Core::Component
  class Dynamic < Base

    def initialize(*_args)
      super

      # TODO: no idea why this is called `url_params` it contains
      # much more than this e.g. almost all params so maybe rename it?
      # used only in dynamic it seems?
      @url_params = context&.[](:params)&.except(:action, :controller, :component_key)
      # only relevant to isolate?!
      @component_key = @options[:component_key]

      # Options for seemingly advanced functionality
      # This is the configuration for the VueJS component
      @component_config = @options.except(:context, :children, :url_params, :included_config)

      generate_component_name
    end

    def show
      render :dynamic_without_rerender
    end

    private
    def dynamic_tag_attributes
      attrs = {
        "is": @component_class,
        "ref": component_id,
        ":params":  @url_params.to_json,
        ":component-config": @component_config.to_json,
        "inline-template": true,
      }
      attrs.merge!(options[:attributes]) unless options[:attributes].nil?
      attrs
    end

    # TODO: this is also basically legacy/magically reliant on naming
    # scheme with the same custom name prefix.
    # We might want to make that more explicit and/or also reliant on the
    # registry registered name.
    # Which wouldn't work anymore with add_child ClassName
    # Can we just have this be the whole module name or you have to
    # explicitly name it?
    def generate_component_name
      name_parts = self.class.name.split("::")
      module_name = name_parts[0]
      if module_name == "Components"
        name_parts[0] = "Custom"
      end
      if name_parts.count > 1
        if name_parts.include?("Cell")
          name = name_parts[0] + name_parts[1]
          if name_parts[0] == name_parts[2]
            name = name_parts[0] + name_parts[1]
            @component_class =  name.underscore.gsub("_", "-")
          else
            name = name_parts[0] + name_parts[2] + name_parts[1]
            @component_class = name.underscore.gsub("_", "-")
          end
        else
          if name_parts[-2] == name_parts[-1]
            @component_class = name_parts[0..-2].join("-").downcase
          else
            @component_class = name_parts.join("-").downcase
          end
        end
      else
        name = name_parts[0]
        @component_class = name.underscore.gsub("_", "-")
      end
      @component_name = @component_class
    end
  end
end
