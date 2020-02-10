class Sandbox::SandboxController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper

  def hello
    responder_for(Pages::Sandbox::Hello)
  end

end
