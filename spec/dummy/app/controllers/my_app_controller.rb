class MyAppController < ApplicationController

  include Matestack::Ui::Core::ApplicationHelper
  include Components::Registry
  include Demo::Components::Registry

  matestack_app Demo::App

  def my_first_page
    render Demo::Pages::MyFirstPage
  end

  def my_second_page
    render Demo::Pages::MySecondPage
  end

  def my_third_page
    render Demo::Pages::MyThirdPage
  end

  def my_fourth_page
    render Demo::Pages::MyFourthPage
  end

  def my_fifth_page
    render Demo::Pages::MyFifthPage
  end

  def my_sixth_page
    render Demo::Pages::MySixthPage
  end

  def collection
    render Demo::Pages::Collection
  end

  def inline_edit
    render Demo::Pages::InlineEdit
  end

  def rails_view_and_partial
    @title = 'Test Title'
    render Demo::Pages::RailsViewAndPartial
  end

  def some_action
    render json: {}, status: :ok
  end

  def form_action
    dummy_model = DummyModel.create(dummy_model_params)
    if dummy_model.errors.any?
      render json: {
        errors: dummy_model.errors,
        message: "Test Model could not be saved!"
      }, status: :unprocessable_entity
    else
      ActionCable.server.broadcast("matestack_ui_core", {
        event: "test_model_created",
        data: [matestack_component(:my_list_item, item: dummy_model), matestack_component(:my_list_item, item: dummy_model)]
      })
      render json: { transition_to: my_second_page_path }, status: :created
    end
  end

  def inline_form_action
    @dummy_model = DummyModel.find(params[:id])
    @dummy_model.update(dummy_model_params)
    if @dummy_model.errors.any?
      render json: {
        errors: @dummy_model.errors,
        message: "Test Model could not be saved!"
      }, status: :unprocessable_entity
    else
      broadcast "test_model_created"
      render json: @dummy_model, status: :created
    end
  end

  def delete_dummy_model
    @dummy_model = DummyModel.find(params[:id])
    if @dummy_model.destroy
      ActionCable.server.broadcast("matestack_ui_core", {
        event: "test_model_deleted",
        data: "item-#{params[:id]}"
      })
      render json: {}, status: :ok
    else
      render json: {
        errors: @dummy_model.errors,
        message: "Test Model could not be deleted!"
        }, status: :unprocessable_entity
    end

  end

  protected

  def dummy_model_params
    params.require(:dummy_model).permit(
      :title,
      :description,
      :status
    )
  end

  def broadcast message, item=nil
    ActionCable.server.broadcast("matestack_ui_core", {
      message: message,
      new_element: matestack_component(:my_list_item, item: item).to_s
    })
  end

end
