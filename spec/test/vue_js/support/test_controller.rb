class TestController < ActionController::Base
  before_action :check_params

  def check_params
    expect_params(params.permit!.to_h)
  end

  def expect_params(params)
  end
end
