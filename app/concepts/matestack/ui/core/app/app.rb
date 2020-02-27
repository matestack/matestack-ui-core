module Matestack::Ui::Core::App

  # TODO: Similar to page, App doesn't need everything base offers atm
  class App < Matestack::Ui::Core::Component::Base

    def initialize(page_class, controller_instance, context)
      super(nil, context: context)

      @page_class = page_class
      @controller_instance = controller_instance
    end

    def show
      render :app
    end

    # Default "response" for just rendering the page without a more
    # sophisticated app being supplied
    def response
      page_content
    end

    def page_content
      # TODO: Content probably needs/would benefit from a better name - like "DynamicWrapper" ?
      add_child Matestack::Ui::Core::Page::Content do
        add_child @page_class,
                  controller_instance: @controller_instance,
                  context: context
      end
    end
  end
end
