module Matestack::Ui::Core::App
  # TODO: Similar to page, App doesn't need everything base offers atm
  class App < Matestack::Ui::Core::Component::Base
    include Matestack::Ui::Core::Cell
    include Matestack::Ui::Core::ApplicationHelper
    # include Matestack::Ui::Core::ToCell
    include Matestack::Ui::Core::HasViewContext

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

    # new alternative method name to be used in app defentions
    # slots may contain a loading state element will be rendered during form start to finish of a transition
    def yield_page slots: {}
      page_content_wrapper slots: slots do
        add_child @page_class,
                  controller_instance: @controller_instance,
                  context: context
      end
    end

    def page_content slots: {}
      yield_page slots: slots
    end


    # def page_content loading_state_element_slot: nil
    #   # TODO: Content probably needs/would benefit from a better name - like "DynamicWrapper" ?
    #   context[:loading_state_element_slot] = loading_state_element_slot
    #   add_child Matestack::Ui::Core::Page::Content, context: context do
    #     add_child @page_class,
    #               controller_instance: @controller_instance,
    #               context: context
    #   end
    # end
  end
end
