class ExampleController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def page
    responder_for(ExamplePage)
  end

end
