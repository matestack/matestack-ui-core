module Matestack
  module Ui
    module Core
      # We're called ApplicationHelper but all we do so far is rendering.
      module ApplicationHelper

        # Allow the definition of a controller wide get_matestack_app_class
        #
        #     class SomeController < ActionController::Base
        #       matestack_app MyAppClass
        #       #...
        #     end
        #
        def self.included(base)
          base.extend(ClassMethods)
        end
        module ClassMethods
          def matestack_app _class
            @matestack_app_class = _class
          end

          def get_matestack_app_class
            if defined?(@matestack_app_class)
              @matestack_app_class
            else
              nil
            end
          end

        end

        # Matestack allows you to use `render` to render matestack pages.
        #
        #     render Pages::Member::Bookings::Index
        #     render matestack: Pages::Member::Bookings::Index
        #
        def render(*args)
          if (matestack_class = args.first).is_a?(Class) && (matestack_class < Matestack::Ui::Page)
            options_hash = args[1].is_a?(Hash) ? args[1] : {}
            Rendering::MainRenderer.render(self, matestack_class, options_hash)
          elsif (options = args.first).is_a?(Hash) &&
                  (matestack_arg = options[:matestack]) &&
                  matestack_arg.is_a?(Class) &&
                  (matestack_arg < Matestack::Ui::Page)
            Rendering::MainRenderer.render(self, matestack_arg, options)
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

        # Kept around for compatibility. Probably worth removing.
        def responder_for(*args)
          render(*args)
        end
      end
    end
  end
end
