module Matestack::Ui::Core::Collection::Filter
  class Filter < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name 'matestack-ui-core-collection-filter'

    def setup
      @component_config = @component_config.except(:data, :paginated_data)
    end

    def response
      div html_attributes do
        yield_components
      end
    end

  end
end
