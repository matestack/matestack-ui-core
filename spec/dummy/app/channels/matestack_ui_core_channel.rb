class MatestackUiCoreChannel < ApplicationCable::Channel

  def subscribed
    stream_from "matestack_ui_core"
  end

end
