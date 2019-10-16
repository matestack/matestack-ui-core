class ApiController < ApplicationController

  def data
    render json: ["some", "server", "data"]
  end

  def single_endpoint
    user = "user number #{params[:number]}"
    render json: [user]
  end

end
