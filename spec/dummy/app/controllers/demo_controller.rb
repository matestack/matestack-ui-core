class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper

  def first
    render FirstPage
  end

end