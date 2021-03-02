module Matestack
  module Ui
    module Core
      module Slots

        attr_accessor :slots

        def slot(content = nil, &block)
          if content
            plain content
          else
            Matestack::Ui::Core::Base.new(:slot, nil, {}, &block).render_content
          end
        end

      end
    end
  end
end