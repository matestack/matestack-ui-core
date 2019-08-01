module Matestack::Ui::Core::Collection::Order::Toggle::Indicator
  class Indicator < Matestack::Ui::Core::Component::Static

    def response
      components {
        plain "{{orderIndicator( '#{@component_config[:key]}', {asc: '#{@component_config[:asc]}', desc: '#{@component_config[:desc]}'} ) }}"
      }
    end

  end
end
