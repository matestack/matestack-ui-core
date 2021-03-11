class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper
  matestack_app Demo::App

  def first
    render Demo::FirstPage, user: 'Nils'
  end

  def second
    render Demo::SecondPage
  end

  def action
    if params[:test][:foo]
      render json: {}, status: :ok
    else
      render json: { errors: { foo: ['missing'] } }, status: :unprocessable_entity
    end
    ActionCable.server.broadcast('matestack_ui_core', { 
      event: 'replace',
      data: Demo::Components::Time.()
    })
  end

  def speed
    render Demo::Index
  end

  def index
    # view_context.javascript_pack_tag 'application'
    render 'rails/index', layout: 'application'
  end

end