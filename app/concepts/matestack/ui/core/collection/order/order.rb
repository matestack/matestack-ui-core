module Matestack::Ui::Core::Collection::Order
  class Order < Matestack::Ui::Core::Component::Dynamic

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
