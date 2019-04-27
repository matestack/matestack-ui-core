class MyAppController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper

  def my_first_page
    responder_for(Pages::MyApp::MyFirstPage)
  end

  def my_second_page
    responder_for(Pages::MyApp::MySecondPage)
  end

  def my_third_page
    responder_for(Pages::MyApp::MyThirdPage)
  end

  def my_fourth_page
    responder_for(Pages::MyApp::MyFourthPage)
  end

  def my_fifth_page
    responder_for(Pages::MyApp::MyFifthPage)
  end

  def my_sixth_page
    responder_for(Pages::MyApp::MySixthPage)
  end

  def some_action
    render json: {}, status: :ok
  end

  def form_action
    @dummy_model = DummyModel.create(dummy_model_params)
    if @dummy_model.errors.any?
      render json: {
        errors: @dummy_model.errors,
        message: "Test Model could not be saved!"
      }, status: :unproccessable_entity
    else
      broadcast "test_model_created"
      render json: @dummy_model, status: :created
    end
  end

  protected

  def dummy_model_params
    params.require(:dummy_model).permit(
      :title,
      :description
    )
  end

  def broadcast message
    ActionCable.server.broadcast("matestack_ui_core", {
      message: message
    })
  end

end
