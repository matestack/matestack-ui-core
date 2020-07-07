module Matestack::Ui::Core::Collection::Filter
  class Filter < Matestack::Ui::Core::Component::Dynamic

    def vuejs_component_name
      'matestack-ui-core-collection-filter'
    end

    def setup
      @component_config = @component_config.except(:data, :paginated_data)
    end

    def response
      components {
        div @tag_attributes do
          yield_components
        end
      }
    end

  end
end
