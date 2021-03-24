class ExampleController < ApplicationController
  include Matestack::Ui::Core::Helper
  matestack_app App

  def page
    render ExamplePage
  end

  def base
    render BaseExamplePage
  end

end
