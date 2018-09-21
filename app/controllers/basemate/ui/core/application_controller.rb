module Basemate
  module Ui
    module Core
      class ApplicationController < ActionController::Base
        protect_from_forgery with: :exception
      end
    end
  end
end
