module Matestack::Ui::Core::Collection::Content
  class Content < Matestack::Ui::Core::Component::Dynamic

    def setup
      @rerender = true
      @component_config = @component_config.except(:data, :paginated_data)
    end


    def response
      components {
        div do
          yield_components
        end
      }
    end


  end
end
