class DemoCoreController < ActionController::Base
  include Matestack::Ui::Core::Helper

  layout "application_core"

  matestack_layout Demo::Core::Layout

  def first
    render Demo::Core::Pages::FirstPage
  end

  def second
    render Demo::Core::Pages::SecondPage
  end

end
