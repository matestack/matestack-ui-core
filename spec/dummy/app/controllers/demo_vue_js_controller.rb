class DemoVueJsController < ActionController::Base
  include Matestack::Ui::Core::Helper

  layout "application_vue_js"
  matestack_layout Demo::VueJs::Layout

  def first
    render Demo::VueJs::Pages::FirstPage
  end

  def second
    render Demo::VueJs::Pages::SecondPage
  end

  def ssr_call
    ActionCable.server.broadcast("matestack_ui_vue_js", {
      event: "some_server_event",
      data: Demo::VueJs::Components::StaticComponent.call(foo: "bar from server")
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
