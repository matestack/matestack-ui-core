module Matestack::Ui::Core::Component
  class Dynamic < Base
    def show
      render :dynamic_without_rerender
    end
  end
end
