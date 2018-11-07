class FormTestsController < ApplicationController

  include Basemate::Ui::Core::ApplicationHelper

  def input
    responder_for(Pages::FormTests::InputTest)
  end

end
