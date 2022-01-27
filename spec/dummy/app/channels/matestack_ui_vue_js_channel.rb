class MatestackUiVueJsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "matestack_ui_vue_js"
  end

end
