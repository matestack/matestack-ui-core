module Matestack::Ui::Core::Render

  # Matestack allows you to use `render` to render matestack pages.
  #
  #     render Pages::Member::Bookings
  #     render matestack: Pages::Member::Bookings
  #     render matestack: 'member/bookings'
  #
  def render(*args)
    if (matestack_class = args.first).is_a?(Class) && (matestack_class < Matestack::Ui::Page)
      responder_for matestack_class
    elsif (options = args.first).kind_of?(Hash) && (matestack_arg = options[:matestack]).present?
      if (matestack_path = matestack_arg).kind_of? String
        matestack_path = "pages/#{matestack_path}" unless matestack_path.start_with?("pages/") or matestack_path.start_with?("components/")
        matestack_class = matestack_path.split("/").collect { |str| str.camelcase }.join("::").constantize
      elsif matestack_arg.is_a?(Class) && (matestack_arg < Matestack::Ui::Page)
        matestack_class = matestack_arg
      end
      responder_for matestack_class
    else
      super
    end
  end

  # Matestack allows implicit rendering. When an `index` or `show` action is requested, which is not
  # defined, then the matestack page is inferred from the controller name. The index action will
  # look for a `Page` with a plural name, the show action will look for a `Page` with a singular
  # name.
  #
  #     class Clients::BookingsController < ApplicationController
  #       def index
  #         @bookings = Booking.all
  #       end
  #
  #       def show
  #         @booking = Booking.find params[:id]
  #       end
  #     end
  #
  # In this example, `clients/bookings#index` will render `Pages::Clients::Bookings`,
  # `clients/bookings#show` will render `Pages::Clients::Booking`.
  #
  # Custom action names translate also into page names.
  #
  #     class Clients::BookingsController < ApplicationController
  #       def step1
  #       end
  #     end
  #
  # In this example, the `clients/bookings#step1` action will render
  # `Pages::Clients::Bookings::Step1`.
  #
  def default_render(*args)
    matestack_page_path = "pages/#{controller_path}"
    matestack_page_path = "#{matestack_page_path}/#{action_name}" unless action_name.in? %w(index show)
    matestack_class_name_parts = matestack_page_path.split("/").collect { |str| str.camelcase }
    matestack_class_name_parts[-1] = matestack_class_name_parts[-1].singularize if action_name == "show"
    matestack_class_name = matestack_class_name_parts.join("::")
    begin
      matestack_class = matestack_class_name.constantize
    rescue NameError
    end
    if matestack_class
      render matestack: matestack_class
    else
      super
    end
  end

end