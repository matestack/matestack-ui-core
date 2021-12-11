class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper
  
  matestack_app Demo::App

  def first
    render Demo::Pages::FirstPage
  end

  def second
    render Demo::Pages::SecondPage
  end

end
