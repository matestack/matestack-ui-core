class FormTestsController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper

  def input
    responder_for(Pages::FormTests::InputTest)
  end

  def submit
    if params[:my_object][:my_key] == "hello"
      render status: 200, json: { message: "ok" }
    else
      render status: 400, json: {
        message: "wrong input",
        errors: { my_key: ["should be hello"] }
      }
    end
  end

  def back
    responder_for(Pages::FormTests::BackPage)
  end

end
