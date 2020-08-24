module Matestack::Ui::Core::Collection::Order::Toggle::Indicator
  class Indicator < Matestack::Ui::Core::Component::Static

    def response
      span html_attributes do
        span attributes: {"v-if": "ordering['#{@component_config[:key]}'] === undefined"}, text: @component_config[:default]
        unescaped "{{
          orderIndicator('#{@component_config[:key]}', { asc: '#{@component_config[:asc]}', desc: '#{@component_config[:desc]}'})
        }}"
      end
    end

  end
end
