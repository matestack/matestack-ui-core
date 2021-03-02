class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper
  include Demo::Components::Registry
  matestack_app Demo::App

  def first
    render Demo::FirstPage
  end

  def second
    render Demo::SecondPage
  end

  def action
    render json: {}, status: :ok
  end

end