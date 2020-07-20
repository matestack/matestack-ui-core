class ExampleController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  def page
    render ExamplePage
  end

  def base
    render BaseExamplePage
  end

end
