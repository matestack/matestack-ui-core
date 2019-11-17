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

end