module Matestack::Ui::Core::Page
  class Content < Matestack::Ui::Core::Component::Dynamic

    def response
      div class: "matestack-page-container", attributes: loading_classes do
        if options[:slots] && options[:slots][:loading_state]
          div class: "loading-state-element-wrapper", attributes: loading_classes do
            slot options[:slots][:loading_state]
          end
        end
        div class: "matestack-page-wrapper", attributes: loading_classes  do
          div attributes: { "v-if": "asyncPageTemplate == null" } do
            yield_components
          end
          div attributes: { "v-if": "asyncPageTemplate != null" } do
            plain content_tag("v-runtime-template", nil, ":template": "asyncPageTemplate")
          end
        end
      end
    end

    def loading_classes
      { "v-bind:class": "{ 'loading': loading === true }" }
    end

  end
end
