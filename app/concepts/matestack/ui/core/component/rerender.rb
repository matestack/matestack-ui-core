module Matestack::Ui::Core::Component
  # NAME PENDING
  class Rerender < Dynamic
    def show
      # TODO duplication here removed/moved somewhere else
      prepare

      # likely won't need this anymore anyhow
      if respond_to? :response
        render :response_dynamic
      else
        render :dynamic
      end
    end
  end
end
