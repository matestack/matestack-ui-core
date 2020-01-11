module Matestack::Ui::Core::Render

  # Matestack allows you to use `render` to render matestack pages.
  #
  #     render Pages::Member::Bookings::Index
  #     render matestack: Pages::Member::Bookings::Index
  #     render matestack: 'member/bookings/index'
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
  # In this example, `clients/bookings#index` will render `Pages::Clients::Bookings::Index`,
  # `clients/bookings#show` will render `Pages::Clients::Bookings::Show`.
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
    if matestack_page_class = default_render_matestack_page_class
      render matestack: matestack_page_class
    else
      super
    end
  end

  def possible_default_render_matestack_page_paths
    paths = []
    paths << "pages/#{controller_path}/#{action_name}"
    paths << "pages/#{controller_path}" if action_name == "index"
    paths << "pages/#{controller_path.singularize}" if action_name == "show"
    paths << "#{controller_path}/#{action_name}_page"
    paths << "#{controller_path}_page" if action_name == "index"
    paths << "#{controller_path.singularize}_page" if action_name == "show"
    paths
  end

  def possible_default_render_matestack_page_class_names
    possible_default_render_matestack_page_paths.collect { |page_path|
      page_path.split("/").collect { |str| str.camelcase }.join("::")
    }
  end

  def default_render_matestack_page_class
    possible_default_render_matestack_page_class_names.each do |class_name|
      begin
        return matestack_class = class_name.constantize
      rescue NameError
      end
    end
    return nil
  end

end