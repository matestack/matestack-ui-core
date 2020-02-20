module Matestack
  module Ui
    module Core
      # We're called ApplicationHelper but all we do so far is rendering.
      module ApplicationHelper

        # Matestack allows you to use `render` to render matestack pages.
        #
        #     render Pages::Member::Bookings::Index
        #     render matestack: Pages::Member::Bookings::Index
        #     TODO: Removed:
        #     render matestack: 'member/bookings/index'
        #
        def render(*args)
          if (matestack_class = args.first).is_a?(Class) && (matestack_class < Matestack::Ui::Page)
            options_hash = args[1].is_a?(Hash) ? args[1] : {}
            Rendering::MainRenderer.render(self, matestack_class, options_hash, params)
          elsif (options = args.first).is_a?(Hash) &&
                  (matestack_arg = options[:matestack]) &&
                  matestack_arg.is_a?(Class) &&
                  (matestack_arg < Matestack::Ui::Page)
            Rendering::MainRenderer.render(self, matestack_arg, options, params)
          else
            super
          end
        end

        # TODO: maybe/Axe remove this?
        # Matestack allows implicit rendering. The matestack page class name is inferred from the
        # controller path and action name.
        #
        #     class Clients::BookingsController < ApplicationController
        #       def index
        #         @bookings = Booking.all
        #         # looks for Pages::Clients::Bookings::Index
        #       end
        #
        #       def show
        #         @booking = Booking.find params[:id]
        #         # looks for Pages::Clients::Bookings::Show
        #       end
        #     end
        #
        # In this example, `clients/bookings#index` will render `Pages::Clients::Bookings::Index`,
        # `clients/bookings#show` will render `Pages::Clients::Bookings::Show`.
        #
        # Custom action names translate also into page names.
        #
        #     class Clients::BookingsController < ApplicationController
        #       def step1
        #         # looks for Pages::Clients::Bookings::Step1
        #       end
        #     end
        #
        # In this example, the `clients/bookings#step1` action will render
        # `Pages::Clients::Bookings::Step1`.
        #
        def default_render(*args)
          matestack_page_class =
            Rendering::DefaultRendererClassDeterminer.determine_class(controller_path, action_name)
          if matestack_page_class
            render matestack_page_class
          else
            super
          end
        end

        # TODO: I highly recommend deprecating this, as the name reminds
        # of responders (https://github.com/heartcombo/responders) but it seemingly
        # has nothing to do with it?
        # Kept around for compatibility.
        def responder_for(*args)
          render(*args)
        end
      end
    end
  end
end
