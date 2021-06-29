class ModelFormTestController < TestController
  include Matestack::Ui::Core::Helper
  matestack_app App

  def model_submit
    @test_model = TestModel.create(model_params)
    if @test_model.errors.any?
      render json: {
        message: "server says: something went wrong!",
        errors: @test_model.errors
      }, status: :unprocessable_entity
    else
      render json: {
        message: "server says: form submitted successfully!"
      }, status: :ok
    end
  end

  protected

  def model_params
    params.require(:test_model).permit(:title, :description, :status, some_data: [], more_data: [])
  end
end
