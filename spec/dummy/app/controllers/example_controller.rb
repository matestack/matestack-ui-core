class ExampleController < ApplicationController
  include Matestack::Ui::Core::Helper

  def page
    render ExamplePage
  end

  def base
    render BaseExamplePage
  end

end
