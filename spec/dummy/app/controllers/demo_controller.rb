class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper
  include Demo::Components::Registry
  matestack_app Demo::App

  def first
    render Demo::FirstPage, user: 'Nils'
  end

  def second
    render Demo::SecondPage
  end

  def action
    render json: {}, status: :ok
    ActionCable.server.broadcast('matestack_ui_core', { 
      event: 'replace',
      data: Demo::Components::Time.()
    })
  end

end