class DemoController < ActionController::Base
  include Matestack::Ui::Core::Helper

  matestack_app Demo::App

  def first
    render Demo::Pages::FirstPage
    # render html: Demo::Components::StaticComponent.call(foo: "bar"), layout: 'application'
  end

  def second
    render Demo::Pages::SecondPage
  end

  def ssr_call
    ActionCable.server.broadcast("matestack_ui_core", {
      event: "some_server_event",
      data: Demo::Components::StaticComponent.call(foo: "bar from server")
    })
  end

  def form_submit
    if params[:some_object][:some_key].blank?
      render json: { errors: { some_key: ["can't be blank"] } }, status: :unprocessable_entity
    else
      render json: {}, status: :created
    end
  end

end
