class ApiController < ApplicationController

  def data
    render json: ["some", "server", "data"]
  end

end
