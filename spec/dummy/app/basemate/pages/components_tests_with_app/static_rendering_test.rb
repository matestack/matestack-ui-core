require_relative "../../../../../support/components"

class Pages::ComponentsTestsWithApp::StaticRenderingTest < Page::Cell::Page

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

    }
  end

end
