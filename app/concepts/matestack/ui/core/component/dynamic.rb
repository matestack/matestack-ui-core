module Matestack::Ui::Core::Component
  class Dynamic < Base
    def show
      # TODO duplication here removed/moved somewhere else
      prepare

      # likely won't need this anymore anyhow
      if respond_to? :response
        render :response_dynamic_without_rerender
      else
        render :dynamic_without_rerender
      end
    end
  end
end
