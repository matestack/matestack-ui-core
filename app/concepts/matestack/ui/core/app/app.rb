module Matestack::Ui::Core::App

  # TODO: Similar to page, App doesn't need everything base offers atm
  class App < Matestack::Ui::Core::Component::Base

    def initialize(page_class, options)
      # TODO: double check if those options are really useful as handed down here
      super(nil, options)

      @page_class = page_class
      context = options.fetch(:context)
      @controller_instance = context.fetch(:controller_instance)
    end

    def show()
      prepare
      response
      render :app
    end

    # Default "response" for just rendering the page without a more
    # sophisticated app being supplied
    def response
      page_content
    end

    def page_content
      add_child @page_class, controller_instance: @controller_instance
    end
  end
end
