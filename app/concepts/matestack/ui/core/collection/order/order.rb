module Matestack::Ui::Core::Collection::Order
  class Order < Matestack::Ui::Core::Component::Dynamic
    vue_js_component_name 'matestack-ui-core-collection-order'

    def setup
      @component_config = @component_config.except(:data, :paginated_data)
    end

    def response
      div @tag_attributes do
        yield_components
      end
    end

  end
end
