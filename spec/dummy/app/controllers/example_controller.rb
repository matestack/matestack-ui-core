class ExampleController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def page
    responder_for(ExamplePage)
  end

  def base
    responder_for(BaseExamplePage)
  end

end
