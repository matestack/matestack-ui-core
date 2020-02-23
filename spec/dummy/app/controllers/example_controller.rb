class ExampleController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def page
    responder_for(ExamplePage)
  end

  def turbolinks
    responder_for(ExamplePage, {options: 'turbolinks'})
  end

end
