require_relative "../../../../../support/components"

class Pages::ComponentsTests::StaticRenderingTest < Page::Cell::Page

  def prepare
    @component_specs = Support::Components.specs

    @component = context[:params][:component]
    @component_spec = @component_specs.with_indifferent_access[@component]
  end

  def response
    components {

      @component_spec[:options][:optional].each do |optional_option, option_type|
        attrs = {}
        case option_type
        when :string
          attrs[optional_option.to_sym] = "attr_value"
        when :hash
          attrs[optional_option.to_sym] = { key1: "value1", key2: "value2" }
        when :boolean
          attrs[optional_option.to_sym] = true
        end
        self.send(@component, attrs)
      end

      if @component_spec[:block] == true
        self.send(@component, {id: "with_block"}) do
          plain "block content"
        end
      end

      unless @component_spec[:optional_dynamics].nil?

        if @component_spec[:optional_dynamics][:rerender_on][:client_side_event] == true
          self.send(@component, {id: "rerender_on_client_side_event", dynamic: true}) do
            plain DateTime.now.strftime('%Q')
          end
        end

      end

    }
  end

end
