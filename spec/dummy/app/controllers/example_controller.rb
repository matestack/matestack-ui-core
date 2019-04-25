class ExampleController < ApplicationController
  include Basemate::Ui::Core::ApplicationHelper

  def page
    responder_for(ExamplePage)
  end

end
