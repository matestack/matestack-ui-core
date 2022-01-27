require_relative 'layout'

class ExampleController < ApplicationController
  include Matestack::Ui::Core::Helper

  layout "application_core"
  matestack_layout Layout

  def page
    render ExamplePage
  end

  def base
    render BaseExamplePage
  end

end
